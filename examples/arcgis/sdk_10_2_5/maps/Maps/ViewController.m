//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize mapView = _mapView;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[AGSMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.mapView.layerDelegate = self;
    
    [self.view addSubview:self.mapView];
    
    // We will try to load esri's world map layer to test if the SDK can display the map layer.
    NSString * esri_wmts_url = @"http://sampleserver6.arcgisonline.com/arcgis/rest/services/WorldTimeZones/MapServer/WMTS";
    
    NSString * om2_prod_wmts_url = @"http://mapservices.onemap.sg/wmts";
    
# warning Note: We are shall use the improved WMTS map link for this example. It is currently going through UAT thus we will push it to production soon.
    
    NSString * om2_uat_wmts_url = @"http://mapproxy.onemap.sg/wmts/1.0.0/WMTSCapabilities.xml";
    
    
    self.wmtsInfo = [[AGSWMTSInfo alloc] initWithURL:[NSURL URLWithString:esri_wmts_url]];
    
    self.wmtsInfo.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - AGSMapViewLayerDelegate Methods

- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    [self.mapView.locationDisplay startDataSource];
}


#pragma mark - AGSWMTSInfoDelegate Methods

- (void)wmtsInfoDidLoad:(AGSWMTSInfo *)wmtsInfo
{
    NSArray * layerInfos = [wmtsInfo layerInfos];
    
    AGSWMTSLayerInfo * layerInfo = [layerInfos objectAtIndex:0];
    
    NSLog(@"Loading layer: %@", layerInfo.title);
    
    
    
    self.wmtsLayer = [wmtsInfo wmtsLayerWithLayerInfo:layerInfo andSpatialReference:nil];
    
    [self.wmtsLayer setDelegate:self];
    
    [self.mapView addMapLayer:self.wmtsLayer withName:@"wmts Layer"];
}

- (void)wmtsInfo:(AGSWMTSInfo *)wmtsInfo didFailToLoad:(NSError *)error
{
    NSLog(@"WMTS Info Failed To Load: %@", error.localizedDescription);
}


#pragma mark - AGSLayerDelegate Methods

- (void)layerDidLoad:(AGSLayer *)layer
{
    NSLog(@"layerDidLoadForLayerName : %@", layer.name);
}

- (void)layer:(AGSLayer *)layer didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Layer Failed To Load: %@", error.localizedDescription);
}

@end
