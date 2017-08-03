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
    
    AGSWMTSInfo * wmtsInfo;
    
    AGSWMTSLayer * currentBaseMapLayer;
    
    NSArray <AGSWMTSLayerInfo *> * wmtsLayerInfos;
}

@property(nonatomic, retain) IBOutlet AGSMapView * mapView;

@end

@implementation ViewController
@synthesize mapView;


NSString * defaultMapStyle = @"DEFAULT";

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
    
    [self.view addSubview:mapView];

    
    NSURL * url = [NSURL URLWithString:@"https://mapservices.onemap.sg/wmts"];
    
    wmtsInfo = [AGSWMTSInfo wmtsInfoWithURL:url];
    
    [wmtsInfo setDelegate:self];
}

#pragma mark - AGSMapViewLayerDelegate Methods

- (void)mapViewDidLoad:(AGSMapView *)_mapView
{
    NSLog(@"mapViewDidLoad");
}


#pragma mark - AGSLayerDelegate Methods

- (void)layerDidLoad:(AGSLayer *)layer
{
    NSLog(@"layerDidLoad");
    
    if(layer == currentBaseMapLayer)
    {
        [mapView addMapLayer:currentBaseMapLayer withName:@"basemap"];
    
        [mapView zoomToEnvelope:layer.fullEnvelope animated:NO];
    }
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

- (void)wmtsInfoDidLoad:(AGSWMTSInfo *)_wmtsInfo
{
    wmtsLayerInfos = [_wmtsInfo layerInfos];
    
    if(wmtsLayerInfos && wmtsLayerInfos.count > 1)
    {
        for(AGSWMTSLayerInfo * layerInfo in wmtsLayerInfos)
        {
            NSString * title = layerInfo.title;
            
            if(title && [title.uppercaseString isEqualToString:defaultMapStyle])
            {
                currentBaseMapLayer = [AGSWMTSLayer
                                       wmtsLayerWithWMTSInfo:wmtsInfo
                                       wmtsLayerInfo:layerInfo
                                       spatialReference:nil];
                
                [currentBaseMapLayer setDelegate:self];
                
                return;
            }
        }
    }
    
    NSLog(@"Unable to initialize WMTS Layer");
}

- (void)wmtsInfo:(AGSWMTSInfo *)wmtsInfo didFailToLoad:(NSError *)error
{
    NSLog(@"WMTS Info Failed To Load: %@", error.localizedDescription);
}


@end
