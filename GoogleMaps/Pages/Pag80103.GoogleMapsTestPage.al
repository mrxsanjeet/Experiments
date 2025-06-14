page 80103 "Google Maps Test Page"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Google Maps Test Page';

    layout
    {
        area(Content)
        {
            group("Coordinate Input")
            {
                Caption = 'Coordinate Input';

                field(TestLatitude; TestLatitude)
                {
                    ApplicationArea = All;
                    Caption = 'Latitude';
                    ToolTip = 'Enter latitude coordinate';
                    DecimalPlaces = 6 : 6;
                }

                field(TestLongitude; TestLongitude)
                {
                    ApplicationArea = All;
                    Caption = 'Longitude';
                    ToolTip = 'Enter longitude coordinate';
                    DecimalPlaces = 6 : 6;
                }

                field(TestAddress; TestAddress)
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                    ToolTip = 'Enter address for the location';
                }

                field(MarkerTitle; MarkerTitle)
                {
                    ApplicationArea = All;
                    Caption = 'Marker Title';
                    ToolTip = 'Enter title for new markers';
                }

                field(MarkerDescription; MarkerDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Marker Description';
                    ToolTip = 'Enter description for new markers';
                    MultiLine = true;
                }

                field(ZoomLevel; ZoomLevel)
                {
                    ApplicationArea = All;
                    Caption = 'Zoom Level';
                    ToolTip = 'Set zoom level (1-20)';
                    MinValue = 1;
                    MaxValue = 20;
                }

                field(MapType; MapType)
                {
                    ApplicationArea = All;
                    Caption = 'Map Type';
                    ToolTip = 'Select map type';
                }
            }

            group("Map Display")
            {
                Caption = 'Interactive Google Map';

                usercontrol(GoogleMapsControl; "Google Maps Addin")
                {
                    ApplicationArea = All;

                    trigger ControlReady()
                    begin
                        MapControlReady := true;
                        InitializeTestMap();
                        Message('Google Maps control is ready!');
                    end;

                    trigger LocationMarked(latitude: Decimal; longitude: Decimal; address: Text)
                    begin
                        TestLatitude := latitude;
                        TestLongitude := longitude;
                        TestAddress := address;
                        CurrPage.Update();
                        Message('Location marked: %1, %2\Address: %3', latitude, longitude, address);
                    end;

                    trigger MapClicked(latitude: Decimal; longitude: Decimal)
                    begin
                        TestLatitude := latitude;
                        TestLongitude := longitude;
                        CurrPage.Update();
                        Message('Map clicked at: %1, %2', latitude, longitude);
                    end;

                    trigger MarkerDragged(latitude: Decimal; longitude: Decimal)
                    begin
                        TestLatitude := latitude;
                        TestLongitude := longitude;
                        CurrPage.Update();
                        Message('Marker dragged to: %1, %2', latitude, longitude);
                    end;
                }
            }

            group("Status Information")
            {
                Caption = 'Status Information';

                field(ControlStatus; GetControlStatus())
                {
                    ApplicationArea = All;
                    Caption = 'Control Status';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = not MapControlReady;
                }

                field(LastAction; LastAction)
                {
                    ApplicationArea = All;
                    Caption = 'Last Action';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Basic Actions")
            {
                Caption = 'Basic Actions';

                action(SetCoordinates)
                {
                    ApplicationArea = All;
                    Caption = 'Set Coordinates';
                    ToolTip = 'Set map center to entered coordinates';
                    Image = SetupColumns;

                    trigger OnAction()
                    begin
                        SetMapCoordinates();
                    end;
                }

                action(SetCoordinatesWithAddress)
                {
                    ApplicationArea = All;
                    Caption = 'Set Coordinates + Address';
                    ToolTip = 'Set map center with address info window';
                    Image = SetupLines;

                    trigger OnAction()
                    begin
                        SetMapCoordinatesWithAddress();
                    end;
                }

                action(AddMarker)
                {
                    ApplicationArea = All;
                    Caption = 'Add Marker';
                    ToolTip = 'Add a marker at the specified coordinates';
                    Image = AddWatch;

                    trigger OnAction()
                    begin
                        AddMapMarker();
                    end;
                }

                action(ClearMarkers)
                {
                    ApplicationArea = All;
                    Caption = 'Clear All Markers';
                    ToolTip = 'Remove all markers from the map';
                    Image = ClearLog;

                    trigger OnAction()
                    begin
                        ClearAllMarkers();
                    end;
                }
            }

            group("Map Settings")
            {
                Caption = 'Map Settings';

                action(SetZoom)
                {
                    ApplicationArea = All;
                    Caption = 'Set Zoom Level';
                    ToolTip = 'Set the map zoom level';
                    Image = Setup;

                    trigger OnAction()
                    begin
                        SetMapZoom();
                    end;
                }

                action(ChangeMapType)
                {
                    ApplicationArea = All;
                    Caption = 'Change Map Type';
                    ToolTip = 'Change the map display type';
                    Image = Map;

                    trigger OnAction()
                    begin
                        ChangeMapDisplayType();
                    end;
                }

                action(EnableDragging)
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

                action(DisableDragging)
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

            group("Location Services")
            {
                Caption = 'Location Services';

                action(GetCurrentLocationAction)
                {
                    ApplicationArea = All;
                    Caption = 'Get Current Location';
                    ToolTip = 'Get current location using browser geolocation';
                    Image = Navigate;

                    trigger OnAction()
                    begin
                        GetCurrentLocationProcedure();
                    end;
                }

                action(ShowInfoWindowAction)
                {
                    ApplicationArea = All;
                    Caption = 'Show Info Window';
                    ToolTip = 'Show an info window at the specified coordinates';
                    Image = Info;

                    trigger OnAction()
                    begin
                        ShowInfoWindowProcedure();
                    end;
                }
            }

            group("Test Data")
            {
                Caption = 'Test Data';

                action(LoadMicrosoftHQ)
                {
                    ApplicationArea = All;
                    Caption = 'Microsoft HQ';
                    ToolTip = 'Load Microsoft Headquarters coordinates';
                    Image = Setup;

                    trigger OnAction()
                    begin
                        LoadTestLocation('Microsoft', 47.6062, -122.3321, 'Microsoft Corporation, Redmond, WA');
                    end;
                }

                action(LoadGoogleHQ)
                {
                    ApplicationArea = All;
                    Caption = 'Google HQ';
                    ToolTip = 'Load Google Headquarters coordinates';
                    Image = Setup;

                    trigger OnAction()
                    begin
                        LoadTestLocation('Google', 37.4220, -122.0841, 'Google LLC, Mountain View, CA');
                    end;
                }

                action(LoadAppleHQ)
                {
                    ApplicationArea = All;
                    Caption = 'Apple HQ';
                    ToolTip = 'Load Apple Headquarters coordinates';
                    Image = Setup;

                    trigger OnAction()
                    begin
                        LoadTestLocation('Apple', 37.3349, -122.0090, 'Apple Inc., Cupertino, CA');
                    end;
                }

                action(AddMultipleMarkers)
                {
                    ApplicationArea = All;
                    Caption = 'Add Multiple Test Markers';
                    ToolTip = 'Add several test markers to demonstrate functionality';
                    Image = AddWatch;

                    trigger OnAction()
                    begin
                        AddMultipleTestMarkers();
                    end;
                }
            }
        }
    }

    var
        TestLatitude: Decimal;
        TestLongitude: Decimal;
        TestAddress: Text;
        MarkerTitle: Text;
        MarkerDescription: Text;
        ZoomLevel: Integer;
        MapType: Option Roadmap,Satellite,Hybrid,Terrain;
        MapControlReady: Boolean;
        LastAction: Text;

    trigger OnOpenPage()
    begin
        // Set default values
        TestLatitude := 47.6062;  // Microsoft HQ
        TestLongitude := -122.3321;
        TestAddress := 'Microsoft Corporation, Redmond, WA';
        MarkerTitle := 'Test Marker';
        MarkerDescription := 'This is a test marker created from Business Central';
        ZoomLevel := 15;
        MapType := MapType::Roadmap;
        LastAction := 'Page opened';
    end;

    local procedure InitializeTestMap()
    begin
        if not MapControlReady then
            exit;

        CurrPage.GoogleMapsControl.SetCoordinatesWithAddress(TestLatitude, TestLongitude, TestAddress);
        CurrPage.GoogleMapsControl.SetZoomLevel(ZoomLevel);
        LastAction := 'Map initialized';
    end;

    local procedure SetMapCoordinates()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.SetCoordinates(TestLatitude, TestLongitude);
        LastAction := StrSubstNo('Coordinates set to %1, %2', TestLatitude, TestLongitude);
        Message(LastAction);
    end;

    local procedure SetMapCoordinatesWithAddress()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.SetCoordinatesWithAddress(TestLatitude, TestLongitude, TestAddress);
        LastAction := StrSubstNo('Coordinates with address set to %1, %2', TestLatitude, TestLongitude);
        Message(LastAction);
    end;

    local procedure AddMapMarker()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.AddMarker(TestLatitude, TestLongitude, MarkerTitle, MarkerDescription);
        LastAction := StrSubstNo('Marker added at %1, %2', TestLatitude, TestLongitude);
        Message(LastAction);
    end;

    local procedure ClearAllMarkers()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.ClearMarkers();
        LastAction := 'All markers cleared';
        Message(LastAction);
    end;

    local procedure SetMapZoom()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.SetZoomLevel(ZoomLevel);
        LastAction := StrSubstNo('Zoom level set to %1', ZoomLevel);
        Message(LastAction);
    end;

    local procedure ChangeMapDisplayType()
    var
        MapTypeText: Text;
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        case MapType of
            MapType::Roadmap:
                MapTypeText := 'roadmap';
            MapType::Satellite:
                MapTypeText := 'satellite';
            MapType::Hybrid:
                MapTypeText := 'hybrid';
            MapType::Terrain:
                MapTypeText := 'terrain';
        end;

        CurrPage.GoogleMapsControl.SetMapType(MapTypeText);
        LastAction := StrSubstNo('Map type changed to %1', MapTypeText);
        Message(LastAction);
    end;

    local procedure EnableMarkerDragging(Enable: Boolean)
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.EnableMarkerDragging(Enable);
        if Enable then
            LastAction := 'Marker dragging enabled'
        else
            LastAction := 'Marker dragging disabled';
        Message(LastAction);
    end;

    local procedure GetCurrentLocationProcedure()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.GetCurrentLocation();
        LastAction := 'Getting current location...';
    end;

    local procedure ShowInfoWindowProcedure()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        CurrPage.GoogleMapsControl.ShowInfoWindow(TestLatitude, TestLongitude,
            '<div><strong>' + MarkerTitle + '</strong><br>' + MarkerDescription + '</div>');
        LastAction := 'Info window shown';
        Message(LastAction);
    end;

    local procedure LoadTestLocation(LocationName: Text; Lat: Decimal; Lng: Decimal; Address: Text)
    begin
        TestLatitude := Lat;
        TestLongitude := Lng;
        TestAddress := Address;
        MarkerTitle := LocationName + ' Headquarters';
        MarkerDescription := 'This is the headquarters location of ' + LocationName;

        if MapControlReady then
            CurrPage.GoogleMapsControl.SetCoordinatesWithAddress(TestLatitude, TestLongitude, TestAddress);

        LastAction := StrSubstNo('%1 location loaded', LocationName);
        CurrPage.Update();
        Message(LastAction);
    end;

    local procedure AddMultipleTestMarkers()
    begin
        if not MapControlReady then begin
            Message('Map control is not ready yet');
            exit;
        end;

        // Add markers for major tech companies
        CurrPage.GoogleMapsControl.AddMarker(47.6062, -122.3321, 'Microsoft', 'Microsoft Corporation HQ');
        CurrPage.GoogleMapsControl.AddMarker(37.4220, -122.0841, 'Google', 'Google LLC HQ');
        CurrPage.GoogleMapsControl.AddMarker(37.3349, -122.0090, 'Apple', 'Apple Inc. HQ');
        CurrPage.GoogleMapsControl.AddMarker(47.6205, -122.3493, 'Amazon', 'Amazon.com Inc. HQ');
        CurrPage.GoogleMapsControl.AddMarker(37.4848, -122.1483, 'Facebook', 'Meta Platforms Inc. HQ');

        LastAction := 'Multiple test markers added';
        Message(LastAction);
    end;

    local procedure GetControlStatus(): Text
    begin
        if MapControlReady then
            exit('Ready')
        else
            exit('Not Ready');
    end;
}
