// Google Maps Implementation for Business Central
// Handles all map operations and AL ⇄ JS communication

console.log('Google Maps: Main script loaded');

// Global variables
var map;
var geocoder;
var currentMarker;

// Initialize Google Map
function initializeGoogleMap() {
    try {
        console.log('Google Maps: Initializing map...');
        
        // Check if Google Maps API is loaded
        if (typeof google === 'undefined' || !google.maps) {
            console.warn('Google Maps API not loaded yet, retrying...');
            setTimeout(initializeGoogleMap, 1000);
            return;
        }
        
        var mapElement = document.getElementById('map');
        if (!mapElement) {
            console.error('Google Maps: Map element not found');
            return;
        }
        
        // Map options
        var mapOptions = {
            center: { lat: window.currentLatitude, lng: window.currentLongitude },
            zoom: window.mapConfig.zoom,
            mapTypeId: google.maps.MapTypeId[window.mapConfig.mapType.toUpperCase()]
        };
        
        // Create the map
        map = new google.maps.Map(mapElement, mapOptions);
        
        // Initialize geocoder
        geocoder = new google.maps.Geocoder();
        
        // Add click listener to map
        map.addListener('click', function(event) {
            var lat = event.latLng.lat();
            var lng = event.latLng.lng();
            
            console.log('Google Maps: Map clicked at', lat, lng);
            
            // Notify AL about map click
            if (typeof Microsoft !== 'undefined' && 
                Microsoft.Dynamics && 
                Microsoft.Dynamics.NAV && 
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod) {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('MapClicked', [lat, lng]);
            }
        });
        
        console.log('Google Maps: Map initialized successfully');
        
    } catch (error) {
        console.error('Google Maps: Error initializing map:', error);
    }
}

// Set coordinates from AL (called by AL code)
function SetCoordinates(latitude, longitude) {
    try {
        console.log('Google Maps: SetCoordinates called with', latitude, longitude);
        
        if (!map) {
            console.warn('Google Maps: Map not initialized, storing coordinates for later');
            window.currentLatitude = latitude;
            window.currentLongitude = longitude;
            setTimeout(function() { SetCoordinates(latitude, longitude); }, 1000);
            return;
        }
        
        var newCenter = new google.maps.LatLng(latitude, longitude);
        
        // Update map center
        map.setCenter(newCenter);
        
        // Clear existing marker
        if (currentMarker) {
            currentMarker.setMap(null);
        }
        
        // Add new marker
        currentMarker = new google.maps.Marker({
            position: newCenter,
            map: map,
            title: 'Location: ' + latitude + ', ' + longitude,
            draggable: window.mapConfig.draggableMarkers
        });
        
        // Add drag listener if dragging is enabled
        if (window.mapConfig.draggableMarkers) {
            currentMarker.addListener('dragend', function(event) {
                var lat = event.latLng.lat();
                var lng = event.latLng.lng();
                
                console.log('Google Maps: Marker dragged to', lat, lng);
                
                // Notify AL about marker drag
                if (typeof Microsoft !== 'undefined' && 
                    Microsoft.Dynamics && 
                    Microsoft.Dynamics.NAV && 
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod) {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('MarkerDragged', [lat, lng]);
                }
            });
        }
        
        // Store current coordinates
        window.currentLatitude = latitude;
        window.currentLongitude = longitude;
        
        console.log('Google Maps: Coordinates set successfully');
        
    } catch (error) {
        console.error('Google Maps: Error setting coordinates:', error);
    }
}

// Set coordinates with address from AL
function SetCoordinatesWithAddress(latitude, longitude, address) {
    try {
        console.log('Google Maps: SetCoordinatesWithAddress called with', latitude, longitude, address);
        
        // First set the coordinates
        SetCoordinates(latitude, longitude);
        
        // Then add info window with address
        if (currentMarker && address) {
            var infoWindow = new google.maps.InfoWindow({
                content: '<div><strong>Address:</strong><br>' + address + '</div>'
            });
            
            currentMarker.addListener('click', function() {
                infoWindow.open(map, currentMarker);
            });
            
            // Show info window immediately
            infoWindow.open(map, currentMarker);
        }
        
    } catch (error) {
        console.error('Google Maps: Error setting coordinates with address:', error);
    }
}

// Add marker from AL
function AddMarker(latitude, longitude, title, description) {
    try {
        console.log('Google Maps: AddMarker called with', latitude, longitude, title, description);
        
        if (!map) {
            console.warn('Google Maps: Map not initialized');
            return;
        }
        
        var position = new google.maps.LatLng(latitude, longitude);
        
        var marker = new google.maps.Marker({
            position: position,
            map: map,
            title: title || 'Marker',
            draggable: window.mapConfig.draggableMarkers
        });
        
        // Add info window if description provided
        if (description) {
            var infoWindow = new google.maps.InfoWindow({
                content: '<div><strong>' + (title || 'Marker') + '</strong><br>' + description + '</div>'
            });
            
            marker.addListener('click', function() {
                // Close other info windows
                window.mapInfoWindows.forEach(function(iw) {
                    iw.close();
                });
                
                infoWindow.open(map, marker);
            });
            
            window.mapInfoWindows.push(infoWindow);
        }
        
        // Store marker
        window.mapMarkers.push(marker);
        
        console.log('Google Maps: Marker added successfully');
        
    } catch (error) {
        console.error('Google Maps: Error adding marker:', error);
    }
}

// Clear all markers
function ClearMarkers() {
    try {
        console.log('Google Maps: ClearMarkers called');
        
        // Clear all markers
        window.mapMarkers.forEach(function(marker) {
            marker.setMap(null);
        });
        window.mapMarkers = [];
        
        // Clear all info windows
        window.mapInfoWindows.forEach(function(infoWindow) {
            infoWindow.close();
        });
        window.mapInfoWindows = [];
        
        // Clear current marker
        if (currentMarker) {
            currentMarker.setMap(null);
            currentMarker = null;
        }
        
        console.log('Google Maps: All markers cleared');
        
    } catch (error) {
        console.error('Google Maps: Error clearing markers:', error);
    }
}

// Set map type from AL
function SetMapType(mapType) {
    try {
        console.log('Google Maps: SetMapType called with', mapType);
        
        if (!map) {
            window.mapConfig.mapType = mapType;
            return;
        }
        
        var googleMapType;
        switch (mapType.toLowerCase()) {
            case 'satellite':
                googleMapType = google.maps.MapTypeId.SATELLITE;
                break;
            case 'hybrid':
                googleMapType = google.maps.MapTypeId.HYBRID;
                break;
            case 'terrain':
                googleMapType = google.maps.MapTypeId.TERRAIN;
                break;
            default:
                googleMapType = google.maps.MapTypeId.ROADMAP;
        }
        
        map.setMapTypeId(googleMapType);
        window.mapConfig.mapType = mapType;
        
        console.log('Google Maps: Map type set to', mapType);
        
    } catch (error) {
        console.error('Google Maps: Error setting map type:', error);
    }
}

// Set zoom level from AL
function SetZoomLevel(zoomLevel) {
    try {
        console.log('Google Maps: SetZoomLevel called with', zoomLevel);
        
        if (!map) {
            window.mapConfig.zoom = zoomLevel;
            return;
        }
        
        map.setZoom(zoomLevel);
        window.mapConfig.zoom = zoomLevel;
        
        console.log('Google Maps: Zoom level set to', zoomLevel);
        
    } catch (error) {
        console.error('Google Maps: Error setting zoom level:', error);
    }
}

// Enable/disable marker dragging
function EnableMarkerDragging(enable) {
    try {
        console.log('Google Maps: EnableMarkerDragging called with', enable);
        
        window.mapConfig.draggableMarkers = enable;
        
        // Update current marker
        if (currentMarker) {
            currentMarker.setDraggable(enable);
        }
        
        // Update all markers
        window.mapMarkers.forEach(function(marker) {
            marker.setDraggable(enable);
        });
        
        console.log('Google Maps: Marker dragging', enable ? 'enabled' : 'disabled');
        
    } catch (error) {
        console.error('Google Maps: Error setting marker dragging:', error);
    }
}

// Show info window at coordinates
function ShowInfoWindow(latitude, longitude, content) {
    try {
        console.log('Google Maps: ShowInfoWindow called');
        
        if (!map) {
            console.warn('Google Maps: Map not initialized');
            return;
        }
        
        var position = new google.maps.LatLng(latitude, longitude);
        
        var infoWindow = new google.maps.InfoWindow({
            content: content,
            position: position
        });
        
        infoWindow.open(map);
        
        console.log('Google Maps: Info window shown');
        
    } catch (error) {
        console.error('Google Maps: Error showing info window:', error);
    }
}

// Get current location using browser geolocation
function GetCurrentLocation() {
    try {
        console.log('Google Maps: GetCurrentLocation called');
        
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;
                    
                    console.log('Google Maps: Current location obtained', lat, lng);
                    
                    // Set map to current location
                    SetCoordinates(lat, lng);
                    
                    // Notify AL
                    if (typeof Microsoft !== 'undefined' && 
                        Microsoft.Dynamics && 
                        Microsoft.Dynamics.NAV && 
                        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod) {
                        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('LocationMarked', [lat, lng, 'Current Location']);
                    }
                },
                function(error) {
                    console.error('Google Maps: Geolocation error:', error);
                }
            );
        } else {
            console.error('Google Maps: Geolocation not supported');
        }
        
    } catch (error) {
        console.error('Google Maps: Error getting current location:', error);
    }
}

// Initialize map when Google Maps API is ready
if (typeof google !== 'undefined' && google.maps) {
    initializeGoogleMap();
} else {
    // Wait for Google Maps API to load
    window.initMap = function() {
        console.log('Google Maps: API loaded, initializing map');
        initializeGoogleMap();
    };
}

console.log('Google Maps: Main script completed');
