// Google Maps Startup Script for Business Central
// This script initializes the map container and notifies AL that the control is ready

console.log('Google Maps Control Add-in: Startup script loaded');

// Initialize the map container
function initializeMapContainer() {
    try {
        // Get the control add-in container
        var controlAddin = document.getElementById('controlAddIn');
        
        if (controlAddin) {
            // Create the map container div
            controlAddin.innerHTML = '<div id="map" style="width: 100%; height: 100%;"></div>';
            
            console.log('Google Maps: Container initialized');
            
            // Set default coordinates (Microsoft Headquarters as fallback)
            window.defaultLatitude = 47.6062;
            window.defaultLongitude = -122.3321;
            window.currentLatitude = window.defaultLatitude;
            window.currentLongitude = window.defaultLongitude;
            
            // Initialize markers array
            window.mapMarkers = [];
            window.mapInfoWindows = [];
            
            // Map configuration
            window.mapConfig = {
                zoom: 15,
                mapType: 'roadmap', // roadmap, satellite, hybrid, terrain
                draggableMarkers: false
            };
            
            console.log('Google Maps: Default configuration set');
            
            // Notify AL that the control is ready
            if (typeof Microsoft !== 'undefined' && 
                Microsoft.Dynamics && 
                Microsoft.Dynamics.NAV && 
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod) {
                
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
                console.log('Google Maps: ControlReady event sent to AL');
            } else {
                console.warn('Google Maps: Microsoft.Dynamics.NAV not available, retrying...');
                // Retry after a short delay
                setTimeout(function() {
                    if (typeof Microsoft !== 'undefined' && 
                        Microsoft.Dynamics && 
                        Microsoft.Dynamics.NAV && 
                        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod) {
                        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
                        console.log('Google Maps: ControlReady event sent to AL (retry)');
                    }
                }, 1000);
            }
        } else {
            console.error('Google Maps: controlAddIn element not found');
        }
    } catch (error) {
        console.error('Google Maps: Error in initializeMapContainer:', error);
    }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeMapContainer);
} else {
    initializeMapContainer();
}

// Global callback for Google Maps API
window.initMap = function() {
    console.log('Google Maps API: Callback initiated');
    // The actual map initialization will be handled in googleMap.js
    // This is just the callback required by Google Maps API
};

console.log('Google Maps: Startup script completed');
