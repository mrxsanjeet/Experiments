table 80107 "Middleware Circuit Breaker"
{
    DataClassification = CustomerContent;
    Caption = 'Middleware Circuit Breaker';

    fields
    {
        field(1; "Endpoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Endpoint';
            NotBlank = true;
        }

        field(2; "Failure Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Failure Count';
            InitValue = 0;
        }

        field(3; "Last Failure Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Failure Time';
        }

        field(4; "State"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'State';
            OptionMembers = Closed,Open,HalfOpen;
            OptionCaption = 'Closed,Open,Half Open';
            InitValue = Closed;
        }

        field(5; "Failure Threshold"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Failure Threshold';
            InitValue = 5;
        }

        field(6; "Timeout Period"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Timeout Period (ms)';
            InitValue = 60000; // 1 minute
        }

        field(7; "Success Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Success Count';
            InitValue = 0;
        }

        field(8; "Half Open Success Threshold"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Half Open Success Threshold';
            InitValue = 3;
        }

        field(9; "Last Success Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Success Time';
        }

        field(10; "Total Requests"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Requests';
            InitValue = 0;
        }

        field(11; "Total Failures"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Failures';
            InitValue = 0;
        }

        field(12; "Total Successes"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Successes';
            InitValue = 0;
        }

        field(13; "Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
            Editable = false;
        }

        field(14; "Modified DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Modified DateTime';
            Editable = false;
        }

        field(15; "Is Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Enabled';
            InitValue = true;
        }

        field(16; "Failure Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Failure Rate (%)';
            DecimalPlaces = 2;
            Editable = false;
        }

        field(17; "Average Response Time"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Average Response Time (ms)';
            Editable = false;
        }

        field(18; "Last Response Time"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Response Time (ms)';
            Editable = false;
        }

        field(19; "Consecutive Failures"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Consecutive Failures';
            InitValue = 0;
        }

        field(20; "Consecutive Successes"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Consecutive Successes';
            InitValue = 0;
        }
    }

    keys
    {
        key(Key1; "Endpoint")
        {
            Clustered = true;
        }
        key(Key2; "State", "Last Failure Time")
        {
        }
        key(Key3; "Failure Count", "State")
        {
        }
        key(Key4; "Is Enabled", "State")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime;
        "Modified DateTime" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Modified DateTime" := CurrentDateTime;
        CalculateFailureRate();
    end;

    procedure IsCircuitOpen(): Boolean
    begin
        if not "Is Enabled" then
            exit(false);

        case "State" of
            "State"::Open:
                exit(IsTimeoutExpired());
            "State"::HalfOpen:
                exit(false);
            "State"::Closed:
                exit(false);
        end;

        exit(false);
    end;

    procedure RecordFailure(Endpoint: Text; ErrorCode: Integer)
    begin
        if not Get(Endpoint) then begin
            Init();
            "Endpoint" := CopyStr(Endpoint, 1, 250);
        end;

        "Total Requests" += 1;
        "Total Failures" += 1;
        "Failure Count" += 1;
        "Consecutive Failures" += 1;
        "Consecutive Successes" := 0;
        "Last Failure Time" := CurrentDateTime;

        // Check if we should open the circuit
        if "Failure Count" >= "Failure Threshold" then
            "State" := "State"::Open;

        Modify();
    end;

    procedure RecordSuccess(Endpoint: Text; ResponseTime: Integer)
    begin
        if not Get(Endpoint) then begin
            Init();
            "Endpoint" := CopyStr(Endpoint, 1, 250);
        end;

        "Total Requests" += 1;
        "Total Successes" += 1;
        "Success Count" += 1;
        "Consecutive Successes" += 1;
        "Consecutive Failures" := 0;
        "Last Success Time" := CurrentDateTime;
        "Last Response Time" := ResponseTime;
        UpdateAverageResponseTime(ResponseTime);

        // Handle state transitions
        case "State" of
            "State"::Open:
                // Circuit is open, but we got a success - this shouldn't happen normally
                // but if it does, we might want to transition to half-open
                if "Consecutive Successes" >= "Half Open Success Threshold" then
                    "State" := "State"::HalfOpen;
            "State"::HalfOpen:
                if "Consecutive Successes" >= "Half Open Success Threshold" then
                    "State" := "State"::Closed;
            "State"::Closed:
                // Reset failure count on success in closed state
                if "Consecutive Successes" >= 5 then
                    "Failure Count" := 0;
        end;

        Modify();
    end;

    procedure RecordSuccess(Endpoint: Text)
    begin
        RecordSuccess(Endpoint, 0);
    end;

    procedure TransitionToHalfOpen(Endpoint: Text)
    begin
        if Get(Endpoint) then begin
            "State" := "State"::HalfOpen;
            "Success Count" := 0; // Reset success count for half-open testing
            "Consecutive Successes" := 0;
            Modify();
        end;
    end;

    procedure ResetCircuit(Endpoint: Text)
    begin
        if Get(Endpoint) then begin
            "State" := "State"::Closed;
            "Failure Count" := 0;
            "Success Count" := 0;
            "Consecutive Failures" := 0;
            "Consecutive Successes" := 0;
            "Last Failure Time" := 0DT;
            "Last Success Time" := CurrentDateTime;
            Modify();
        end;
    end;

    local procedure IsTimeoutExpired(): Boolean
    var
        TimeoutDateTime: DateTime;
    begin
        if "Last Failure Time" = 0DT then
            exit(false);

        TimeoutDateTime := "Last Failure Time" + "Timeout Period";
        exit(CurrentDateTime >= TimeoutDateTime);
    end;

    local procedure CalculateFailureRate()
    begin
        if "Total Requests" > 0 then
            "Failure Rate" := Round(("Total Failures" / "Total Requests") * 100, 0.01)
        else
            "Failure Rate" := 0;
    end;

    local procedure UpdateAverageResponseTime(ResponseTime: Integer)
    var
        TotalResponseTime: Integer;
    begin
        if "Total Successes" <= 1 then begin
            "Average Response Time" := ResponseTime;
        end else begin
            TotalResponseTime := "Average Response Time" * ("Total Successes" - 1) + ResponseTime;
            "Average Response Time" := TotalResponseTime / "Total Successes";
        end;
    end;

    procedure GetCircuitState(Endpoint: Text): Option
    begin
        if Get(Endpoint) then
            exit("State")
        else
            exit("State"::Closed);
    end;

    procedure GetFailureCount(Endpoint: Text): Integer
    begin
        if Get(Endpoint) then
            exit("Failure Count")
        else
            exit(0);
    end;

    procedure GetFailureRate(Endpoint: Text): Decimal
    begin
        if Get(Endpoint) then
            exit("Failure Rate")
        else
            exit(0);
    end;

    procedure GetAverageResponseTime(Endpoint: Text): Integer
    begin
        if Get(Endpoint) then
            exit("Average Response Time")
        else
            exit(0);
    end;

    procedure IsHealthy(Endpoint: Text): Boolean
    begin
        if not Get(Endpoint) then
            exit(true);

        exit(("State" = "State"::Closed) and ("Failure Rate" < 50));
    end;

    procedure GetHealthScore(Endpoint: Text): Integer
    var
        HealthScore: Integer;
    begin
        if not Get(Endpoint) then
            exit(100);

        HealthScore := 100;

        // Deduct points for failures
        HealthScore -= Round("Failure Rate" * 0.5, 1);

        // Deduct points for consecutive failures
        HealthScore -= "Consecutive Failures" * 5;

        // Deduct points for high response times
        if "Average Response Time" > 5000 then
            HealthScore -= 20
        else if "Average Response Time" > 2000 then
            HealthScore -= 10;

        // Ensure minimum score of 0
        if HealthScore < 0 then
            HealthScore := 0;

        exit(HealthScore);
    end;

    procedure CleanupOldEntries(DaysOld: Integer)
    var
        CutoffDateTime: DateTime;
        DeletedCount: Integer;
    begin
        CutoffDateTime := CurrentDateTime - (DaysOld * 24 * 60 * 60 * 1000);

        SetFilter("Last Success Time", '<%1', CutoffDateTime);
        SetFilter("Last Failure Time", '<%1', CutoffDateTime);

        if FindSet(true) then
            repeat
                Delete(true);
                DeletedCount += 1;
            until Next() = 0;

        // Note: CleanupOldEntries is a procedure, not a function
        // exit(DeletedCount);
    end;

    procedure GetCircuitBreakerStatistics(): Text
    var
        ClosedCount: Integer;
        OpenCount: Integer;
        HalfOpenCount: Integer;
    begin
        SetRange("State", "State"::Closed);
        ClosedCount := Count();

        SetRange("State", "State"::Open);
        OpenCount := Count();

        SetRange("State", "State"::HalfOpen);
        HalfOpenCount := Count();

        exit(StrSubstNo(
            'Circuit Breaker Status - Closed: %1, Open: %2, Half-Open: %3',
            ClosedCount, OpenCount, HalfOpenCount
        ));
    end;

    procedure SetFailureThreshold(Endpoint: Text; Threshold: Integer)
    begin
        if Get(Endpoint) then begin
            "Failure Threshold" := Threshold;
            Modify();
        end;
    end;

    procedure SetTimeoutPeriod(Endpoint: Text; TimeoutMs: Integer)
    begin
        if Get(Endpoint) then begin
            "Timeout Period" := TimeoutMs;
            Modify();
        end;
    end;

    procedure EnableCircuitBreaker(Endpoint: Text)
    begin
        if Get(Endpoint) then begin
            "Is Enabled" := true;
            Modify();
        end;
    end;

    procedure DisableCircuitBreaker(Endpoint: Text)
    begin
        if Get(Endpoint) then begin
            "Is Enabled" := false;
            Modify();
        end;
    end;
}
