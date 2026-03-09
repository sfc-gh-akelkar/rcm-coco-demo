-- ============================================================================
-- T-SQL Stored Procedure: EM Collections Per Visit
-- Source: Legacy SQL Server EDW (Emergency Medicine service line)
-- Purpose: Cortex Code demo Part 1 — paste this into CoCo and ask it to
--          convert to Snowflake SQL
-- ============================================================================

CREATE PROCEDURE [dbo].[usp_CalculateEMCollectionsPerVisit]
    @StartDate DATE,
    @EndDate DATE,
    @FacilityID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReportDate DATETIME = GETDATE();

    IF OBJECT_ID('tempdb..#ClaimsSummary') IS NOT NULL
        DROP TABLE #ClaimsSummary;

    SELECT
        c.ClaimID,
        c.PatientAccountNumber,
        c.EncounterID,
        c.FacilityID,
        f.FacilityName,
        c.ProviderNPI,
        p.ProviderName,
        p.ProviderSpecialty,
        c.ServiceDate,
        c.CPTCode,
        c.PrimaryDiagnosisCode,
        c.PayerID,
        py.PayerName,
        py.PayerType,
        c.BilledAmount,
        ISNULL(c.AllowedAmount, 0) AS AllowedAmount,
        ISNULL(c.PaidAmount, 0) AS PaidAmount,
        ISNULL(c.PatientResponsibility, 0) AS PatientResponsibility,
        ISNULL(c.AdjustmentAmount, 0) AS AdjustmentAmount,
        c.ClaimStatus,
        c.DenialReasonCode,
        DATEDIFF(DAY, c.ServiceDate, c.FirstPaymentDate) AS DaysToPayment,
        CASE
            WHEN c.ClaimStatus = 'DENIED' THEN 1
            ELSE 0
        END AS IsDenied,
        CASE
            WHEN c.CPTCode BETWEEN '99281' AND '99285' THEN
                CAST(RIGHT(c.CPTCode, 1) AS INT)
            ELSE NULL
        END AS EMLevel,
        ROW_NUMBER() OVER (
            PARTITION BY c.EncounterID
            ORDER BY c.BilledAmount DESC
        ) AS ClaimRank
    INTO #ClaimsSummary
    FROM dbo.Claims c WITH (NOLOCK)
    INNER JOIN dbo.Facilities f ON c.FacilityID = f.FacilityID
    INNER JOIN dbo.Providers p ON c.ProviderNPI = p.ProviderNPI
    INNER JOIN dbo.Payers py ON c.PayerID = py.PayerID
    WHERE c.ServiceDate BETWEEN @StartDate AND @EndDate
      AND c.ServiceLineCode = 'EM'
      AND c.ClaimStatus IN ('PAID', 'DENIED', 'PARTIAL', 'ADJUDICATED')
      AND (c.FacilityID = @FacilityID OR @FacilityID IS NULL);

    CREATE NONCLUSTERED INDEX IX_ClaimsSummary_Facility
        ON #ClaimsSummary (FacilityID, ProviderNPI, ServiceDate);

    SELECT
        cs.FacilityID,
        cs.FacilityName,
        cs.ProviderNPI,
        cs.ProviderName,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, cs.ServiceDate), 0) AS ReportMonth,
        COUNT(DISTINCT cs.EncounterID) AS TotalVisits,
        COUNT(DISTINCT cs.ClaimID) AS TotalClaims,
        SUM(cs.BilledAmount) AS TotalBilled,
        SUM(cs.PaidAmount) AS TotalCollected,
        SUM(cs.AdjustmentAmount) AS TotalAdjustments,
        SUM(cs.PatientResponsibility) AS TotalPatientResp,
        CAST(
            CASE WHEN COUNT(DISTINCT cs.EncounterID) > 0
                 THEN SUM(cs.PaidAmount) / COUNT(DISTINCT cs.EncounterID)
                 ELSE 0
            END AS DECIMAL(10,2)
        ) AS CollectionsPerVisit,
        CAST(
            CASE WHEN SUM(cs.BilledAmount) > 0
                 THEN SUM(cs.PaidAmount) / SUM(cs.BilledAmount) * 100
                 ELSE 0
            END AS DECIMAL(5,2)
        ) AS CollectionRate,
        SUM(cs.IsDenied) AS DenialCount,
        CAST(
            CASE WHEN COUNT(*) > 0
                 THEN CAST(SUM(cs.IsDenied) AS FLOAT) / COUNT(*) * 100
                 ELSE 0
            END AS DECIMAL(5,2)
        ) AS DenialRate,
        AVG(CAST(cs.DaysToPayment AS FLOAT)) AS AvgDaysToPayment,
        AVG(CAST(cs.EMLevel AS FLOAT)) AS AvgEMLevel,
        STRING_AGG(
            CASE WHEN cs.IsDenied = 1 THEN cs.DenialReasonCode ELSE NULL END,
            ','
        ) AS DenialReasons,
        @ReportDate AS GeneratedAt
    FROM #ClaimsSummary cs
    WHERE cs.ClaimRank = 1
    GROUP BY
        cs.FacilityID,
        cs.FacilityName,
        cs.ProviderNPI,
        cs.ProviderName,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, cs.ServiceDate), 0)
    ORDER BY
        cs.FacilityName,
        cs.ProviderName,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, cs.ServiceDate), 0);

    DROP TABLE #ClaimsSummary;
END;
GO
