//
//  ViewController.m
//  Polygons
//
//  Created by Alan Zhu on 22/8/17.
//  Copyright © 2017 Singapore Land Authority. All rights reserved.
//

#import "ViewController.h"
#import <Mapbox/Mapbox.h>

@interface ViewController () <MGLMapViewDelegate>
{
    IBOutlet MGLMapView * mapView;
    
    UITapGestureRecognizer * mapViewTapGestureRecognizer;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initMapView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Map Methods

/**
 * Initialize Map View and set the tab bar's the initial map style option.
 */

- (void)initMapView
{
    NSString * urlString = @"https://maps-json.onemap.sg/Grey.json";
    
    // Get the .json link for the selected basemap.
    NSURL * mapStyleURL = [NSURL URLWithString:urlString];
    
    
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
                       zoomLevel:10.0f
                        animated:NO];
    
    
    // Add our own gesture recognizer to handle taps on our custom map features.
    mapViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(mapViewTapGestureHandler:)];
    
    [mapView addGestureRecognizer:mapViewTapGestureRecognizer];
    
    
    
    // Add map view below the tab bar
    [self.view addSubview:mapView];
}


#pragma mark - Map View Delegate

- (void)mapViewDidFinishLoadingMap:(nonnull MGLMapView *)_mapView
{
    [self loadPolygonsDataFromFile];
}


#pragma mark - Single Tap Gesture Handler

- (void)mapViewTapGestureHandler:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:sender.view];
        
        CGRect pointRect = {point, CGSizeZero};
        
        CGRect touchRect = CGRectInset(pointRect, -16.0, -16.0);
        
        
        // Get first features within a rect the size of a touch (32x32).
        
        for (id annotation in [mapView visibleFeaturesInRect:touchRect])
        {
            if ([annotation isKindOfClass:[MGLPolygonFeature class]])
            {
                MGLPolygonFeature * polygon = (MGLPolygonFeature *) annotation;
                
                if(polygon && polygon.attributes)
                {
                    NSDictionary * attributes = polygon.attributes;
                    
                    NSString * message = [NSString stringWithFormat:@"You have selected %@",
                                          attributes[@"name"]];
                    
                    [self showOKAlertWithTitle:@"Polygon Selected" message:message];
                }
                
                return;
            }
        }
    }
}


#pragma mark - JSON Data Methods

- (void)loadPolygonsDataFromFile
{
    NSError * error;
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"polygons" ofType:@"json"];
    
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    
    if(error)
    {
        [self showOKAlertWithTitle:@"Error" message:@"Unable to import polygons.json"];
        
        return;
    }
    
    // Extract GeoJSON data into polygon features
    
    NSArray * polygons = json[@"Polygons"];
    
    NSMutableArray * polygonFeatures = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0 ; i < polygons.count; i++)
    {
        NSDictionary * polygon = polygons[i];
        
        NSArray * coordinates = polygon[@"coordinates"][0];
        
        CLLocationCoordinate2D * coords = calloc(coordinates.count, sizeof(CLLocationCoordinate2D));
        
        for (NSUInteger k = 0 ; k < coordinates.count; k++)
        {
            NSArray * coordinate = coordinates[k];
            
            NSNumber * lng = coordinate[0];
            
            NSNumber * lat = coordinate[1];
            
            coords[k] = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
        }
        
        MGLPolygonFeature * polygonFeature = [MGLPolygonFeature
                                              polygonWithCoordinates:coords
                                              count:coordinates.count];
        
        NSString * polygonName = [NSString stringWithFormat:@"polygon_%@", [NSNumber numberWithInteger:i].stringValue];
        
        NSDictionary * attributes = @{ @"name" : polygonName };
        
        [polygonFeature setAttributes:attributes];
        
        free(coords);
        
        [polygonFeatures addObject:polygonFeature];
    }
    
    
    // To shape source is required to create a layer.
    
    MGLShapeSource * polygonDataSource = [[MGLShapeSource alloc]
                                          initWithIdentifier:@"polygonLayerDataSource"
                                          features:polygonFeatures
                                          options:nil];
    
    MGLFillStyleLayer * polygonLayer = [self createFillStyleLayerWithShapeSource:polygonDataSource
                                                                           color:[UIColor blueColor] identifier:@"polygonLayer"];
    
    
    // Add layer to map
    [mapView.style addSource:polygonDataSource];
    
    [mapView.style addLayer:polygonLayer];
}


/**
 * Creates a polygon fill style layer.
 *
 @discussion 
    <b>MGLFillStyleLayer:</b>
    https://www.mapbox.com/ios-sdk/api/3.6.2/Classes/MGLFillStyleLayer.html
 
    @param source Polygon data source.
    @param color Color of the polygon.
    @param identifier Unique layer identifier.
    @return An initialized fill style layer.
 */

- (MGLFillStyleLayer *)createFillStyleLayerWithShapeSource:(MGLShapeSource *)source
                                                  color:(UIColor *)color
                                             identifier:(NSString *)identifier
{
    MGLFillStyleLayer * layer = [[MGLFillStyleLayer alloc]
                                 initWithIdentifier:identifier
                                 source:source];
    
    layer.sourceLayerIdentifier = source.identifier;
    
    layer.fillOutlineColor = [MGLStyleValue valueWithRawValue:color];
    
    layer.fillColor = [MGLStyleValue valueWithRawValue:color];
    
    layer.fillOpacity = [MGLStyleValue valueWithRawValue:[NSNumber numberWithFloat:0.3f]];
    
    return layer;
}


#pragma mark - Alert Methods

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
