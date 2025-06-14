pageextension 80200 "Customer Card Google Maps" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            group("Location Information")
            {
                Caption = 'Location Information';

                field(Latitude; Latitude)
                {
                    ApplicationArea = All;
                    Caption = 'Latitude';
                    ToolTip = 'Enter the latitude coordinate for the customer location';
                    DecimalPlaces = 6 : 6;

                    trigger OnValidate()
                    begin
                        UpdateMapLocation();
                    end;
                }

                field(Longitude; Longitude)
                {
                    ApplicationArea = All;
                    Caption = 'Longitude';
                    ToolTip = 'Enter the longitude coordinate for the customer location';
                    DecimalPlaces = 6 : 6;

                    trigger OnValidate()
                    begin
                        UpdateMapLocation();
                    end;
                }
            }
        }

        addlast(content)
        {
            group("Google Maps")
            {
                Caption = 'Customer Location Map';

                usercontrol(GoogleMapsControl; "Google Maps Addin")
                {
                    ApplicationArea = All;

                    trigger ControlReady()
                    begin
                        MapControlReady := true;
                        InitializeMap();
                    end;

                    trigger LocationMarked(latitude: Decimal; longitude: Decimal; address: Text)
                    begin
                        HandleLocationMarked(latitude, longitude, address);
                    end;

                    trigger MapClicked(latitude: Decimal; longitude: Decimal)
                    begin
                        HandleMapClicked(latitude, longitude);
                    end;

                    trigger MarkerDragged(latitude: Decimal; longitude: Decimal)
                    begin
                        HandleMarkerDragged(latitude, longitude);
                    end;
                }
            }
        }
    }

    actions
    {
        addlast("&Customer")
        {
            group("Location Actions")
            {
                Caption = 'Location Actions';

                action(SetCurrentLocation)
                {
                    ApplicationArea = All;
                    Caption = 'Get Current Location';
                    ToolTip = 'Get the current location using browser geolocation';
                    Image = Navigate;

                    trigger OnAction()
                    begin
                        GetCurrentLocation();
                    end;
                }

                action(SetCoordinates)
                {
                    ApplicationArea = All;
                    Caption = 'Set Coordinates';
                    ToolTip = 'Set map center to the entered coordinates';
                    Image = SetupColumns;

                    trigger OnAction()
                    begin
                        UpdateMapLocation();
                    end;
                }

                action(ClearMap)
                {
                    ApplicationArea = All;
                    Caption = 'Clear Map';
                    ToolTip = 'Clear all markers from the map';
                    Image = ClearLog;

                    trigger OnAction()
                    begin
                        ClearMapMarkers();
                    end;
                }

                action(SetMapTypeRoadmap)
                {
                    ApplicationArea = All;
                    Caption = 'Roadmap View';
                    ToolTip = 'Switch to roadmap view';
                    Image = Map;

                    trigger OnAction()
                    begin
                        SetMapType('roadmap');
                    end;
                }

                action(SetMapTypeSatellite)
                {
                    ApplicationArea = All;
                    Caption = 'Satellite View';
                    ToolTip = 'Switch to satellite view';
                    Image = Picture;

                    trigger OnAction()
                    begin
                        SetMapType('satellite');
                    end;
                }

                action(AddTestMarkers)
                {
                    ApplicationArea = All;
                    Caption = 'Add Test Markers';
                    ToolTip = 'Add some test markers to demonstrate functionality';
                    Image = AddWatch;

                    trigger OnAction()
                    begin
                        AddTestMarkers();
                    end;
                }

                action(EnableMarkerDragging)
                {
                    ApplicationArea = All;
                    Caption = 'Enable Marker Dragging';
                    ToolTip = 'Enable dragging of map markers';
                    Image = MoveUp;

                    trigger OnAction()
                    begin
                        EnableMarkerDragging(true);
                    end;
                }

                action(DisableMarkerDragging)
                {
                    ApplicationArea = All;
                    Caption = 'Disable Marker Dragging';
                    ToolTip = 'Disable dragging of map markers';
                    Image = MoveDown;

                    trigger OnAction()
                    begin
                        EnableMarkerDragging(false);
                    end;
                }
            }
        }
    }

    var
        Latitude: Decimal;
        Longitude: Decimal;
        MapControlReady: Boolean;

    trigger OnAfterGetRecord()
    begin
        // Load coordinates from customer record or set defaults
        LoadCustomerCoordinates();

        // Update map if control is ready
        if MapControlReady then
            InitializeMap();
    end;

    local procedure LoadCustomerCoordinates()
    begin
        // Set default coordinates (Microsoft Headquarters)
        if (Latitude = 0) and (Longitude = 0) then begin
            Latitude := 47.6062;
            Longitude := -122.3321;
        end;

        // In a real implementation, you might load these from custom fields
        // or calculate them from the customer's address
    end;

    local procedure InitializeMap()
    begin
        if not MapControlReady then
            exit;

        // Set initial coordinates with customer address
        CurrPage.GoogleMapsControl.SetCoordinatesWithAddress(
            Latitude,
            Longitude,
            GetCustomerAddress()
        );

        // Set initial zoom level
        CurrPage.GoogleMapsControl.SetZoomLevel(15);
    end;

    local procedure UpdateMapLocation()
    begin
        if not MapControlReady then
            exit;

        if (Latitude <> 0) and (Longitude <> 0) then begin
            CurrPage.GoogleMapsControl.SetCoordinatesWithAddress(
                Latitude,
                Longitude,
                GetCustomerAddress()
            );
            Message('Map updated to coordinates: %1, %2', Latitude, Longitude);
        end else begin
            Message('Please enter valid latitude and longitude coordinates');
        end;
    end;

    local procedure HandleLocationMarked(latitude: Decimal; longitude: Decimal; address: Text)
    begin
        Latitude := latitude;
        Longitude := longitude;
        CurrPage.Update();
        Message('Location marked: %1, %2\Address: %3', latitude, longitude, address);
    end;

    local procedure HandleMapClicked(latitude: Decimal; longitude: Decimal)
    begin
        Latitude := latitude;
        Longitude := longitude;
        CurrPage.Update();
        Message('Map clicked at: %1, %2', latitude, longitude);
    end;

    local procedure HandleMarkerDragged(latitude: Decimal; longitude: Decimal)
    begin
        Latitude := latitude;
        Longitude := longitude;
        CurrPage.Update();
        Message('Marker dragged to: %1, %2', latitude, longitude);
    end;

    local procedure GetCurrentLocation()
    begin
        if not MapControlReady then
            exit;

        CurrPage.GoogleMapsControl.GetCurrentLocation();
    end;

    local procedure ClearMapMarkers()
    begin
        if not MapControlReady then
            exit;

        CurrPage.GoogleMapsControl.ClearMarkers();
        Message('Map markers cleared');
    end;

    local procedure SetMapType(mapType: Text)
    begin
        if not MapControlReady then
            exit;

        CurrPage.GoogleMapsControl.SetMapType(mapType);
        Message('Map type changed to: %1', mapType);
    end;

    local procedure EnableMarkerDragging(enable: Boolean)
    begin
        if not MapControlReady then
            exit;

        CurrPage.GoogleMapsControl.EnableMarkerDragging(enable);
        if enable then
            Message('Marker dragging enabled')
        else
            Message('Marker dragging disabled');
    end;

    local procedure AddTestMarkers()
    begin
        if not MapControlReady then
            exit;

        // Add some test markers around the current location
        CurrPage.GoogleMapsControl.AddMarker(Latitude + 0.001, Longitude + 0.001, 'Test Marker 1', 'This is a test marker north-east of the main location');
        CurrPage.GoogleMapsControl.AddMarker(Latitude - 0.001, Longitude - 0.001, 'Test Marker 2', 'This is a test marker south-west of the main location');
        CurrPage.GoogleMapsControl.AddMarker(Latitude + 0.001, Longitude - 0.001, 'Test Marker 3', 'This is a test marker north-west of the main location');

        Message('Test markers added to the map');
    end;

    local procedure GetCustomerAddress(): Text
    var
        AddressText: Text;
    begin
        AddressText := Rec.Name;
        if Rec.Address <> '' then
            AddressText += ', ' + Rec.Address;
        if Rec.City <> '' then
            AddressText += ', ' + Rec.City;
        if Rec."Post Code" <> '' then
            AddressText += ' ' + Rec."Post Code";
        if Rec."Country/Region Code" <> '' then
            AddressText += ', ' + Rec."Country/Region Code";

        exit(AddressText);
    end;
}
