//
//  ViewController.m
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import "ViewController.h"
#import "MarkerOperation.h"
#import "CustomAnnotationPoint.h"

@interface ViewController ()
{
    MarkerOperation * markerOperation;
}
@end

static CGFloat const MAP_ZOOM_MAX       = 18.0f;

static CGFloat const MAP_ZOOM_MIN       = 10.0f;

static NSString * const MARKER_CUSTOM   = @"marker_custom";

@implementation ViewController
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initMapView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Map Methods

- (void)initMapView
{
    NSString * url = @"https://maps-json.onemap.sg/Grey.json";
    
    //We shall use the Default style for this example.
    NSURL * mapStyleURL = [NSURL URLWithString:url];
    
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


#pragma mark - Map View Delegate

- (void)mapViewDidFinishLoadingMap:(nonnull MGLMapView *)_mapView
{
    //Load markers from markers.json
    [self getMarkerData];
}

// Allow callout view to appear when an annotation is tapped.
- (BOOL)mapView:(MGLMapView *)_mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation
{
    return YES;
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)_mapView imageForAnnotation:(id<MGLAnnotation>)annotation
{
    // Try to reuse the existing ‘marker_custom’ annotation image, if it exists.
    
    MGLAnnotationImage * annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:MARKER_CUSTOM];
    
    // If the ‘marker_custom’ annotation image hasn‘t been set yet, initialize it here.
    if (!annotationImage)
    {
        UIImage *image = [UIImage imageNamed:MARKER_CUSTOM];
        
        // Initialize the ‘marker_custom’ annotation image with the UIImage we just loaded.
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:MARKER_CUSTOM];
    }
    
    return annotationImage;
}

- (UIView *)mapView:(MGLMapView *)mapView leftCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation
{
    if([annotation isKindOfClass:[CustomAnnotationPoint class]])
    {
        CustomAnnotationPoint * customAnnotationPoint = (CustomAnnotationPoint *) annotation;
        
        //Get image from image url.
        NSURL * url = [NSURL URLWithString:customAnnotationPoint.imageURL];
        
        NSData * data = [NSData dataWithContentsOfURL:url];
        
        UIImage * image = [UIImage imageWithData:data];
        
        //Create the image thumbnail.
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        
        [imageView setClipsToBounds:YES];
        
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        [imageView setBounds:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        
        return imageView;
    }
    
    return nil;
}

- (UIView *)mapView:(MGLMapView *)mapView rightCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation
{
    if([annotation isKindOfClass:[CustomAnnotationPoint class]])
    {
        return [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return nil;
}

- (void)mapView:(MGLMapView *)mapView annotation:(id<MGLAnnotation>)annotation calloutAccessoryControlTapped:(UIControl *)control
{
    if([annotation isKindOfClass:[CustomAnnotationPoint class]])
    {
        CustomAnnotationPoint * customAnnotationPoint = (CustomAnnotationPoint *) annotation;
        
        NSURL * url = [NSURL URLWithString:customAnnotationPoint.hyperlink];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Operations

- (void)getMarkerData
{
    if(!markerOperation)
    {
        markerOperation = [[MarkerOperation alloc] initWithDelegate:self];
        
        [markerOperation getDataFromLocalFile];
    }
}

#pragma mark - Operation Delegates

- (void)markerOperationError:(NSError *)error
{
    markerOperation = nil;
    
    //show alert
    UIAlertAction *alertAction = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:nil];
    
    UIAlertController *alertCtrl = [UIAlertController
                                    alertControllerWithTitle:@"Markers"
                                    message:@"Unable to get marker data."
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCtrl addAction:alertAction];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)markerOperationSuccessful:(NSDictionary *)data
{
    markerOperation = nil;
    
    if(data)
    {
        NSArray * markers = [data objectForKey:@"markers"];
        
        for (NSDictionary * marker in markers)
        {
            double latitude = [[marker objectForKey:@"latitude"] doubleValue];
            
            double longitude = [[marker objectForKey:@"longitude"] doubleValue];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            
            //Create and add the marker to map.
            CustomAnnotationPoint * annotationPoint = [[CustomAnnotationPoint alloc] init];
            
            [annotationPoint setCoordinate:coordinate];
            
            [annotationPoint setTitle:[marker objectForKey:@"name"]];
            
            [annotationPoint setSubtitle:[marker objectForKey:@"description"]];
            
            [annotationPoint setHyperlink:[marker objectForKey:@"hyperlink"]];
            
            [annotationPoint setImageURL:[marker objectForKey:@"imageURL"]];
            
            [mapView addAnnotation:annotationPoint];
        }
    }
}

@end
