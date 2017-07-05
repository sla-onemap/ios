//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 14/10/16.
//  Copyright © 2016 OneMap. All rights reserved.
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

#import "ViewController.h"

#import <Mapbox/Mapbox.h>

@interface ViewController () <MGLMapViewDelegate, UITabBarDelegate>
{
    IBOutlet MGLMapView * mapView;
    
    IBOutlet UIButton * gpsButton;
    
    IBOutlet UITabBar * tabBar;
    
    NSArray * basemaps;
}
@end

@implementation ViewController

#pragma mark - View Life Cycle Methods
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    basemaps = @[@"Default", @"Original", @"Night", @"Grey"];
    
    [self initMapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

    
#pragma mark - Map Methods

/**
 * Initialize Map View and set the tab bar's the initial map style option.
 */

- (void)initMapView
{
    //Select the first tab bar item.
    [tabBar setSelectedItem:[tabBar.items objectAtIndex:0]];
    
    
    //We shall use the Default style for this example.
    NSString * mapStyle = [basemaps objectAtIndex:tabBar.selectedItem.tag];
    
    
    // Get the .json link for the selected basemap.
    NSURL * mapStyleURL = [self getMapStyleURLForStyle:mapStyle];
    
    
    // Initialize the map view
    mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:mapStyleURL];
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    // Set the delegate property of our map view to self after instantiating it
    [mapView setDelegate:self];
    
    
    // Set the min and max zoom levels of the map view.
    [mapView setMinimumZoomLevel:10.0f];
    
    [mapView setMaximumZoomLevel:18.0f];
    
    
    // Hides the mapbox logo and info button at the bottom
    [mapView.logoView setHidden:YES];
    
    [mapView.attributionButton setHidden:YES];
    
    
    //Set the map's center coordinates and default zoom level to the merlion park.
    CLLocationCoordinate2D merlionParkLocation = CLLocationCoordinate2DMake(1.2867888749929002, 103.8545510172844);
    
    [mapView setCenterCoordinate:merlionParkLocation
                            zoomLevel:12.0f
                             animated:NO];
    
    
    // Add map view below the tab bar
    [self.view insertSubview:mapView belowSubview:tabBar];
}


#pragma mark - IBActions

- (IBAction)gpsTouchUpInside:(UIButton *)button
{
    if(mapView)
    {
        // Toggle user location indicator state.
        if(!button.selected)
        {
            [mapView setShowsUserLocation:YES];
        }
        else
        {
            [mapView setShowsUserLocation:NO];
        }
    }
}


#pragma mark - Map View Delegate
    
- (void)mapViewDidFinishLoadingMap:(nonnull MGLMapView *)_mapView
{
    [self showOKAlertWithTitle:@"Map" message:@"Map successfully loaded."];
}

- (void)mapView:(nonnull MGLMapView *)_mapView didUpdateUserLocation:(nullable MGLUserLocation *)userLocation
{
    if(!gpsButton.selected)
    {
        // Turn on the GPS button.
        [gpsButton setSelected:YES];
    
        [gpsButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
        
        // Zoom to user's location.
        CAMediaTimingFunction * mediaTiming = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        MGLMapCamera * camera = [MGLMapCamera
                                 cameraLookingAtCenterCoordinate:_mapView.userLocation.coordinate
                                 fromDistance:996.0f
                                 pitch:mapView.camera.pitch
                                 heading:mapView.camera.heading];
        
        [_mapView setCamera:camera withDuration:0.6f animationTimingFunction:mediaTiming];
    }
}

- (void)mapViewDidStopLocatingUser:(nonnull MGLMapView *)_mapView
{
    if(gpsButton.selected)
    {
        // Turn off the GPS button.
        [gpsButton setSelected:NO];
        
        [gpsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}


#pragma mark - Tab Bar Delegate
    
- (void)tabBar:(UITabBar *)_tabBar didSelectItem:(UITabBarItem *)_item
{
    if(mapView)
    {
        // Load the selected map style.
        NSURL * mapStyleURL = [self getMapStyleURLForStyle:[basemaps objectAtIndex:_item.tag]];
        
        [mapView setStyleURL:mapStyleURL];
    }
}

/**
 * Initialize Map View and set the Tab Bar's selected item to the initial map style option.
 *
 * @param mapStyle Basemap style to be loaded.
 * @return An URL of the basemap style.
 */

- (NSURL *)getMapStyleURLForStyle:(NSString *)mapStyle
{
    NSString * urlString = [NSString stringWithFormat:@"https://maps-json.onemap.sg/%@.json", mapStyle];
    
    return [NSURL URLWithString:urlString];
}


#pragma mark - Alert View Methods

/**
 * Initialize Map View and set the Tab Bar's selected item to the initial map style option.
 *
 * @param title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
 * @param message Descriptive text that provides additional details about the reason for the alert.
 */

- (void)showOKAlertWithTitle:(NSString *)title message:(NSString *)message
{
    //show alert
    UIAlertAction *alertAction = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:nil];
    
    UIAlertController *alertCtrl = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCtrl addAction:alertAction];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

@end
