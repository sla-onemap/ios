//
//  MarkerOperation.m
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import "MarkerOperation.h"

@implementation MarkerOperation
@synthesize delegate;

#pragma mark - Class Lifecycle Methods

- (id)initWithDelegate:(id <MarkerOperationDelegate> _Nonnull)_delegate
{
    self = [super init];
    
    if (self)
    {
        delegate = _delegate;
    }
    
    return self;
}


#pragma mark - Methods

- (void)getDataFromLocalFile
{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"markers" ofType:@"json"];
    
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    
    
    NSError * error;
    
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if(error)
    {
        [delegate markerOperationError:error];
    }
    else
    {
        [delegate markerOperationSuccessful:result];
    }
}

@end
