controladdin "Google Maps Addin"
{
    RequestedHeight = 400;
    MinimumHeight = 300;
    MaximumHeight = 800;
    RequestedWidth = 800;
    MinimumWidth = 400;
    MaximumWidth = 1200;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    // JavaScript files
    Scripts = 'https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&callback=initMap&libraries=&v=weekly',
              'GoogleMaps\Scripts\googleMap.js';
    
    // Startup script
    StartupScript = 'GoogleMaps\Scripts\googleMapStartup.js';
    
    // CSS styling
    StyleSheets = 'GoogleMaps\Styles\googleMap.css';

    // Events from JavaScript to AL
    event ControlReady();
    event LocationMarked(latitude: Decimal; longitude: Decimal; address: Text);
    event MapClicked(latitude: Decimal; longitude: Decimal);
    event MarkerDragged(latitude: Decimal; longitude: Decimal);

    // Procedures from AL to JavaScript
    procedure SetCoordinates(latitude: Decimal; longitude: Decimal);
    procedure SetCoordinatesWithAddress(latitude: Decimal; longitude: Decimal; address: Text);
    procedure AddMarker(latitude: Decimal; longitude: Decimal; title: Text; description: Text);
    procedure ClearMarkers();
    procedure SetMapType(mapType: Text);
    procedure SetZoomLevel(zoomLevel: Integer);
    procedure EnableMarkerDragging(enable: Boolean);
    procedure ShowInfoWindow(latitude: Decimal; longitude: Decimal; content: Text);
    procedure GetCurrentLocation();
}
