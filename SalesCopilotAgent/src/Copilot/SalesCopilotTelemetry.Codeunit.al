/// <summary>
/// Codeunit for handling telemetry and logging for Sales Copilot
/// Tracks AI interactions, user feedback, and performance metrics
/// </summary>
codeunit 50104 "SJT Sales Copilot Telemetry"
{
    Access = Public;

    var
        Setup: Record "SJT Sales Copilot Setup";
        SetupLoaded: Boolean;
        TelemetryCategoryTxt: Label 'SalesCopilot', Locked = true;

    /// <summary>
    /// Logs a discount recommendation event
    /// </summary>
    procedure LogDiscountRecommendation(pCustomerNo: Code[20]; pDocNo: Code[20]; pSuggestedDiscount: Decimal; pApplied: Boolean)
    var
        customDimensions: Dictionary of [Text, Text];
    begin
        if not IsTelemetryEnabled() then
            exit;

        customDimensions.Add('CustomerNo', pCustomerNo);
        customDimensions.Add('DocumentNo', pDocNo);
        customDimensions.Add('SuggestedDiscount', Format(pSuggestedDiscount));
        customDimensions.Add('Applied', Format(pApplied));

        Session.LogMessage(
            'SCP0001',
            'Discount recommendation generated',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            customDimensions
        );
    end;

    /// <summary>
    /// Logs an anomaly detection event
    /// </summary>
    procedure LogAnomalyDetection(pDocNo: Code[20]; pAnomalyCount: Integer; pAnomalyTypes: Text)
    var
        customDimensions: Dictionary of [Text, Text];
    begin
        if not IsTelemetryEnabled() then
            exit;

        customDimensions.Add('DocumentNo', pDocNo);
        customDimensions.Add('AnomalyCount', Format(pAnomalyCount));
        customDimensions.Add('AnomalyTypes', pAnomalyTypes);

        Session.LogMessage(
            'SCP0002',
            'Anomaly detection completed',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            customDimensions
        );
    end;

    /// <summary>
    /// Logs user feedback on a suggestion
    /// </summary>
    procedure LogUserFeedback(pSuggestionEntryNo: Integer; pStatus: Enum "SJT Suggestion Status"; pAppliedValue: Decimal)
    var
        customDimensions: Dictionary of [Text, Text];
    begin
        if not IsTelemetryEnabled() then
            exit;

        customDimensions.Add('SuggestionEntryNo', Format(pSuggestionEntryNo));
        customDimensions.Add('Status', Format(pStatus));
        customDimensions.Add('AppliedValue', Format(pAppliedValue));

        Session.LogMessage(
            'SCP0003',
            'User feedback recorded',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            customDimensions
        );
    end;

    /// <summary>
    /// Logs customer insight calculation
    /// </summary>
    procedure LogCustomerInsightCalc(pCustomerNo: Code[20]; pTier: Enum "SJT Customer Tier"; pChurnRisk: Decimal)
    var
        customDimensions: Dictionary of [Text, Text];
    begin
        if not IsTelemetryEnabled() then
            exit;

        customDimensions.Add('CustomerNo', pCustomerNo);
        customDimensions.Add('Tier', Format(pTier));
        customDimensions.Add('ChurnRiskScore', Format(pChurnRisk));

        Session.LogMessage(
            'SCP0004',
            'Customer insight calculated',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            customDimensions
        );
    end;

    /// <summary>
    /// Logs Copilot errors
    /// </summary>
    procedure LogError(pOperation: Text; pErrorMessage: Text)
    var
        customDimensions: Dictionary of [Text, Text];
    begin
        customDimensions.Add('Operation', pOperation);
        customDimensions.Add('ErrorMessage', pErrorMessage);

        Session.LogMessage(
            'SCP0099',
            'Sales Copilot error occurred',
            Verbosity::Error,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            customDimensions
        );
    end;

    local procedure IsTelemetryEnabled(): Boolean
    begin
        LoadSetup();
        exit(Setup."Enable Telemetry");
    end;

    local procedure LoadSetup()
    begin
        if SetupLoaded then
            exit;
        Setup.GetSetup();
        SetupLoaded := true;
    end;
}

