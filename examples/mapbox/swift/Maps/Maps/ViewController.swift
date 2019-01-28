//
//  ViewController.swift
//  Maps
//
//  Created by Alan Zhu on 28/1/19.
//  Copyright © 2019 Singapore Land Authority. All rights reserved.
//

/*********************************************************************************
 README
 
 
 Notes:
 Run the project with:
 - Maps.xcworkspace
 
 We are using CocoaPods to install the MapBoxSDK.
 - https://cocoapods.org/
 - https://www.mapbox.com/ios-sdk/
 
 Map Style example:
 - https://www.mapbox.com/ios-sdk/examples/custom-style/
 
 OneMap2 basemap styles Visit:
 -  https://docs.onemap.sg/maps/
 
 Project configurations:
 - Import Settings.bundle into the project
 - info.plist
 - Add the Location Privacy Descriptions.
 - Add App Transport Security Settings to allow Allow Arbitrary Loads.
 
 *********************************************************************************/

import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate, UITabBarDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    
    @IBOutlet var gpsButton: UIButton!
    
    @IBOutlet var tabBar: UITabBar!
    
    var basemaps: NSArray?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        basemaps = ["Default", "Original", "Night", "Grey"];
        
        initMapView();
    }


    /**
     * Initialize Map View and set the tab bar's the initial map style option.
     */
    
    func initMapView()
    {
        // Select the first tab bar item.
        tabBar?.selectedItem = tabBar?.items![0];
        
        
        // We shall use the Default style for this example.
        let mapStyle : String = basemaps?[0] as! String;
        
        
        // Get the .json link for the selected basemap.
        let mapStyleURL : URL = getMapStyleURL(style: mapStyle);
        
        
        // Initialize the map view
        mapView = MGLMapView(frame: view.bounds, styleURL: mapStyleURL);
        
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        
        
        // Set the delegate property of our map view to self after instantiating it
        mapView.delegate = self;
        
        
        // Set the min and max zoom levels of the map view.
        mapView.minimumZoomLevel = 10.0;
        
        mapView.maximumZoomLevel = 18.0;
        
        
        // Hides the mapbox logo and info button at the bottom
        mapView.logoView.alpha = 0.0;
        
        mapView.attributionButton.alpha = 0.0;
        
        
        //Set the map's center coordinates and default zoom level to the merlion park.
        let merlionParkLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(1.2867888749929002, 103.8545510172844);
        
        mapView.setCenter(merlionParkLocation, zoomLevel: 12.0, animated: false);
        
        
        // Add map view below the tab bar
        self.view.insertSubview(mapView, belowSubview: tabBar!);
    }

    @IBAction func gpsTouchUpInside(_ sender: UIButton)
    {
        if(mapView != nil)
        {
            // Toggle user location indicator state.
            mapView?.showsUserLocation = (!sender.isSelected);
        }
    }
    
    
    func mapViewDidFinishLoadingMap(_mapView : MGLMapView)
    {
        
    }
    
    func mapView(_ mapView: MGLMapView, didUpdateUserLocation userLocation: Any!)
    {
        if(!(gpsButton?.isSelected)!)
        {
            // Turn on the GPS button.
            gpsButton?.isSelected = true;
            
            gpsButton?.setTitleColor(UIColor.green, for: .normal);
            
            
            // Zoom to user's location.
            let mediaTiming : CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut);
            
            let camera : MGLMapCamera = MGLMapCamera(lookingAtCenter: mapView.userLocation!.coordinate,
                                                     altitude: 996.0,
                                                     pitch: mapView.camera.pitch,
                                                     heading: mapView.camera.heading);
            
            mapView.setCamera(camera, withDuration: 0.6, animationTimingFunction: mediaTiming);
        }
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MGLMapView)
    {
        if(!(gpsButton?.isSelected)!)
        {
            // Turn off the GPS button.
            gpsButton?.isSelected = false;
            
            gpsButton?.setTitleColor(UIColor.red, for: .normal);
        }
    }
    
    
    func tabBar(_ tabBar : UITabBar, didSelect item: UITabBarItem)
    {
        if(mapView != nil)
        {
            // Load the selected map style.
            let mapStyleURL : URL = getMapStyleURL(style: basemaps![item.tag] as! String);
            
            mapView?.styleURL = mapStyleURL;
        }
    }
    
    /**
     * Initialize Map View and set the Tab Bar's selected item to the initial map style option.
     *
     * @param mapStyle Basemap style to be loaded.
     * @return An URL of the basemap style.
     */
    
    func getMapStyleURL(style: String) -> URL
    {
        let urlString : String = String(format: "https://maps-json.onemap.sg/%@.json", style);
        
        return URL(string: urlString)!;
    }
}
