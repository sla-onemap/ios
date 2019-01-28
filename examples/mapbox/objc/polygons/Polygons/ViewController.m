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
                       zoomLevel:12.0f
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadPolygonsDataFromFile];
    });
}


#pragma mark - Single Tap Gesture Handler

- (void)mapViewTapGestureHandler:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:sender.view];
        
        CGRect pointRect = {point, CGSizeZero};
        
        CGRect touchRect = CGRectInset(pointRect, -8.0, -8.0);
        
        
        // Get first features within a rect the size of a touch (16x16).
        
        for (id annotation in [mapView visibleFeaturesInRect:touchRect])
        {
            if ([annotation isKindOfClass:[MGLPolygonFeature class]])
            {
                MGLPolygonFeature * polygon = (MGLPolygonFeature *) annotation;
                
                if(polygon && polygon.attributes)
                {
                    NSString * name = [polygon attributeForKey:@"name"];
                    
                    [self changeColorBasedOnFeatureName:name];
                }
                
                return;
            }
        }
    }
}


#pragma mark - Feature Methods

- (void)changeColorBasedOnFeatureName:(NSString*)name
{
    MGLLineStyleLayer * lineLayer = (MGLLineStyleLayer *) [mapView.style layerWithIdentifier:@"polylineLayer"];
    
    MGLFillStyleLayer * fillLayer = (MGLFillStyleLayer *) [mapView.style layerWithIdentifier:@"polygonLayer"];
    
    UIColor * defaultLineColor = [UIColor blueColor];
    
    UIColor * defaultFillColor = [UIColor clearColor];
    
    if (name.length > 0)
    {
        /*
         Please read "Migrating from Style Functions to Expressions" > Categorical Section.
         
         Link: https://mapbox.github.io/mapbox-gl-native/macos/0.13.0/migrating-to-expressions.html
         */
        
        lineLayer.lineColor = [NSExpression expressionWithFormat:@"MGL_MATCH(name, %@, %@, %@)",
                               name,
                               [UIColor redColor],
                               defaultLineColor];
        

        fillLayer.fillColor = [NSExpression expressionWithFormat:@"MGL_MATCH(name, %@, %@, %@)",
                               name,
                               [UIColor redColor],
                               defaultFillColor];
    }
    else
    {
        lineLayer.lineColor = [NSExpression expressionForConstantValue:defaultLineColor];
        
        fillLayer.fillColor = [NSExpression expressionForConstantValue:defaultFillColor];
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
    
    NSMutableArray * polylineFeatures = [[NSMutableArray alloc] init];
    
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
        
        NSString * polygonName = [NSString stringWithFormat:@"polygon_%@", [NSNumber numberWithInteger:i].stringValue];
        
        NSDictionary * attributes = @{ @"name" : polygonName };
        
        
        
        MGLPolygonFeature * polygonFeature = [MGLPolygonFeature
                                              polygonWithCoordinates:coords
                                              count:coordinates.count];
        
        [polygonFeature setAttributes:attributes];
        
        
        
        
        MGLPolylineFeature * polylineFeature = [MGLPolylineFeature
                                                polylineWithCoordinates:coords
                                                count:coordinates.count];
        
        [polylineFeature setAttributes:attributes];
        
        
        
        free(coords);
        
        [polygonFeatures addObject:polygonFeature];
        
        [polylineFeatures addObject:polylineFeature];
    }
    
    
    // To shape source is required to create a layer.
    
    MGLShapeSource * polygonDataSource = [[MGLShapeSource alloc]
                                          initWithIdentifier:@"polygonLayerDataSource"
                                          features:polygonFeatures
                                          options:nil];
    
    MGLFillStyleLayer * polygonLayer = [self
                                        createFillStyleLayerWithShapeSource:polygonDataSource
                                        identifier:@"polygonLayer"];
    
    
    MGLShapeSource * polylineDataSource = [[MGLShapeSource alloc]
                                          initWithIdentifier:@"polylineLayerDataSource"
                                          features:polylineFeatures
                                          options:nil];
    
    MGLLineStyleLayer * polylineLayer = [self
                                         createLineStyleLayerWithShapeSource:polylineDataSource
                                         identifier:@"polylineLayer"];
    
    // Add layer to map
    [mapView.style addSource:polygonDataSource];
    
    [mapView.style addLayer:polygonLayer];
    
    
    [mapView.style addSource:polylineDataSource];
    
    [mapView.style addLayer:polylineLayer];
}


#pragma mark - Layer Methods

- (MGLFillStyleLayer *)createFillStyleLayerWithShapeSource:(MGLShapeSource *)source
                                             identifier:(NSString *)identifier
{
    MGLFillStyleLayer * layer = [[MGLFillStyleLayer alloc]
                                 initWithIdentifier:identifier
                                 source:source];
    
    layer.sourceLayerIdentifier = source.identifier;
    
    layer.fillColor = [NSExpression expressionForConstantValue:[UIColor clearColor]];
    
    layer.fillOpacity = [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:1.0f]];
    
    return layer;
}

- (MGLLineStyleLayer *)createLineStyleLayerWithShapeSource:(MGLShapeSource *)source
                                                identifier:(NSString *)identifier
{
    MGLLineStyleLayer * layer = [[MGLLineStyleLayer alloc]
                                 initWithIdentifier:identifier
                                 source:source];
    
    layer.sourceLayerIdentifier = source.identifier;
    
    layer.lineColor = [NSExpression expressionForConstantValue:[UIColor blueColor]];
    
    layer.lineWidth = [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:3.0f]];
    
    layer.lineOpacity = [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:1.0f]];
    
    return layer;
}


#pragma mark - Alert Methods

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
