/// <summary>
/// Entitlement for Sales Copilot extension
/// Grants access to Copilot features based on license type
/// </summary>
entitlement "SJT Sales Copilot"
{
    Type = PerUserServicePlan;
    Id = '00000000-0000-0000-0000-000000000000'; // Replace with actual service plan ID

    ObjectEntitlements =
        "SJT Sales Copilot Objects";
}

