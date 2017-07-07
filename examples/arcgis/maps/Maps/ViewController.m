//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <AGSMapViewLayerDelegate, AGSLayerDelegate, AGSWMTSInfoDelegate>
{
    AGSMapView * mapView;
    
    AGSWMTSInfo * om2WMTSInfo;
    
    AGSWMTSLayer * om2WMTSLayer;
    
    AGSWMTSLayerInfo * om2WMTSLayerInfo;
    
    AGSPoint * centerPoint;
    
    AGSEnvelope * maxEnvelope;
}
@end

@implementation ViewController

NSString * OM2WMTSURL = @"https://mapservices.onemap.sg/wmts";

NSString * OM2TILEJSONURL = @"https://maps-json.onemap.sg/Default.json";

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    mapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    
    [mapView setGridLineColor:[UIColor clearColor]];
    
    [mapView setLayerDelegate:self];
    
    maxEnvelope = [[AGSEnvelope alloc] initWithXmin:12681.357850
                                               ymin:15356.587937
                                               xmax:42020.245328
                                               ymax:53711.071046
                                   spatialReference:nil];

    [mapView setMaxEnvelope:maxEnvelope];
    
    [self.view addSubview:mapView];

    [self initOM2WMTSInfo];
}

#pragma mark - AGSMapViewLayerDelegate Methods

- (void)mapViewDidLoad:(AGSMapView *)_mapView
{
    NSLog(@"mapViewDidLoad");
}

#pragma mark - AGSLayerDelegate Methods

- (void)layerDidLoad:(AGSLayer *)layer
{
    [om2WMTSLayer setStyle:om2WMTSLayerInfo.style];
    
    [mapView zoomToResolution:12 withCenterPoint:maxEnvelope.center animated:YES];
}

- (void)layer:(AGSLayer *)layer didInitializeSpatialReferenceStatus:(BOOL)srStatusValid
{
    NSLog(@"didInitializeSpatialReferenceStatus: %@", layer.name);
}

- (void)layer:(AGSLayer *)layer didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Layer Failed To Load: %@", error.localizedDescription);
}


#pragma mark - AGSWMTSInfoDelegate Methods

- (void)wmtsInfoDidLoad:(AGSWMTSInfo *)wmtsInfo
{
    [self initOM2WMTSLayerWithWMTSInfo:wmtsInfo];
}

- (void)wmtsInfo:(AGSWMTSInfo *)wmtsInfo didFailToLoad:(NSError *)error
{
    NSLog(@"WMTS Info Failed To Load: %@", error.localizedDescription);
}


#pragma mark - WMTS Methods

- (void)initOM2WMTSInfo
{
    NSURL * url = [NSURL URLWithString:OM2WMTSURL];
    
    om2WMTSInfo = [AGSWMTSInfo wmtsInfoWithURL:url];
    
    [om2WMTSInfo setDelegate:self];
}

- (void)initOM2WMTSLayerWithWMTSInfo:(AGSWMTSInfo *)wmtsInfo
{
    om2WMTSInfo = wmtsInfo;
    
    NSArray * layerInfos = [om2WMTSInfo layerInfos];
    
    if(layerInfos && layerInfos.count > 0)
    {
        // Load the Default Map Style
        om2WMTSLayerInfo = [layerInfos objectAtIndex:0];
        
        //Get layerInfo and spatial reference from tileMatrixSetIds
        [om2WMTSLayerInfo setTileMatrixSet:om2WMTSLayerInfo.tileMatrixSetIds[0]];
        
        om2WMTSLayer = [AGSWMTSLayer wmtsLayerWithWMTSInfo:om2WMTSInfo
                                             wmtsLayerInfo:om2WMTSLayerInfo
                                          spatialReference:nil];
        
        [om2WMTSLayer setOpacity:1.0f];
        
        [om2WMTSLayer setStyle:om2WMTSLayerInfo.style];
        
        
        [om2WMTSLayer setDelegate:self];
        
        [mapView addMapLayer:om2WMTSLayer withName:@"basemap"];
    }
    else
    {
        NSLog(@"Unable to initialize WMTS Layer");
    }
}

@end
