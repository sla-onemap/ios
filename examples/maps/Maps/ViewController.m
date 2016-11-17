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
     - Add the location privacy descriptions.
     - Add App Transport Security Settings to allow Allow Arbitrary Loads.
 
*********************************************************************************/

#import "ViewController.h"

@interface ViewController ()
{
    //Track current map style.
    NSInteger mapStyleTag;
    
    NSArray * basemaps;
}
@end

@implementation ViewController
@synthesize mapView;
@synthesize gpsButton;
@synthesize tabBar;

static CGFloat const CAMERA_ANIMATION_DURATION  = 0.6f;

static CGFloat const MAP_ZOOM_DISTANCE          = 996.0f;

static CGFloat const MAP_ZOOM_MAX               = 18.0f;

static CGFloat const MAP_ZOOM_MIN               = 10.0f;

static NSString * const FORMAT_MAP_URL          = @"%@%@%@";
    
static NSString * const URL_MAP                 = @"https://maps-json.onemap.sg/";

static NSString * const URL_MAP_EXTN            = @".json";

    
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

- (void)initMapView
{
    //Select the first tab bar item.
    UITabBarItem * tabBarItem = [self.tabBar.items objectAtIndex:0];
    
    mapStyleTag = tabBarItem.tag;
    
    [self.tabBar setSelectedItem:tabBarItem];
    
    
    //We shall use the Default style for this example.
    NSURL * mapStyleURL = [self getMapStyleURLForStyle:tabBarItem.title];
    
    // Initialize the map view
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:mapStyleURL];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Set the delegate property of our map view to self after instantiating it
    [self.mapView setDelegate:self];
    
    // Set the min and max zoom levels of the map view.
    [self.mapView setMinimumZoomLevel:MAP_ZOOM_MIN];
    
    [self.mapView setMaximumZoomLevel:MAP_ZOOM_MAX];
    
    // Hides the mapbox logo and i button at the bottom
    [self.mapView.logoView setHidden:YES];
    
    [self.mapView.attributionButton setHidden:YES];
    
    //Set the map's center coordinates and default zoom level to the merlion park.
    CLLocationCoordinate2D merlionParkLocation = CLLocationCoordinate2DMake(1.2867888749929002, 103.8545510172844);
    
    [self.mapView setCenterCoordinate:merlionParkLocation zoomLevel:12 animated:NO];
    
    // Add map view to view.
    [self.view addSubview:self.mapView];
    
    // Move map view to the back.
    [self.view sendSubviewToBack:self.mapView];
}


#pragma mark - IBActions

- (IBAction)gpsTouchUpInside:(UIButton *)button
{
    if(self.mapView)
    {
        if(!button.selected)
        {
            [self.mapView setShowsUserLocation:YES];
        }
        else
        {
            [self.mapView setShowsUserLocation:NO];
        }
    }
}


#pragma mark - Map View Delegate
    
- (void)mapViewDidFinishLoadingMap:(nonnull MGLMapView *)_mapView
{
    NSLog(@"Map view successfully loaded.");
}

- (void)mapView:(nonnull MGLMapView *)_mapView didUpdateUserLocation:(nullable MGLUserLocation *)userLocation
{
    if(!gpsButton.selected)
    {
        //Turn on the GPS button.
        [gpsButton setSelected:YES];
    
        [gpsButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
        // Zoom to user location.
        CGFloat pitch = mapView.camera.pitch;
        
        CGFloat heading = mapView.camera.heading;
        
        CAMediaTimingFunction * mediaTiming = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        MGLMapCamera * camera = [MGLMapCamera cameraLookingAtCenterCoordinate:_mapView.userLocation.coordinate fromDistance:MAP_ZOOM_DISTANCE pitch:pitch heading:heading];
        
        [_mapView setCamera:camera withDuration:CAMERA_ANIMATION_DURATION animationTimingFunction:mediaTiming];
    }
}

- (void)mapViewDidStopLocatingUser:(nonnull MGLMapView *)_mapView
{
    if(gpsButton.selected)
    {
        //Turn off the GPS button.
        [gpsButton setSelected:NO];
        
        [gpsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}


#pragma mark - Tab Bar Delegate
    
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(self.mapView && mapStyleTag != item.tag)
    {
        //If the map style is different, change the style URL on the map view.
        mapStyleTag = item.tag;
        
        NSURL * mapStyleURL = [self getMapStyleURLForStyle:[basemaps objectAtIndex:item.tag]];
        
        [self.mapView setStyleURL:mapStyleURL];
    }
}


- (NSURL *)getMapStyleURLForStyle:(NSString *)style
{
    NSString * urlString = [NSString stringWithFormat:FORMAT_MAP_URL,
                            URL_MAP,
                            style,
                            URL_MAP_EXTN];
    
    return [NSURL URLWithString:urlString];
}

@end
