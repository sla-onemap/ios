//
//  MarkerOperationDelegate.h
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

@protocol  MarkerOperationDelegate <NSObject>

@required

- (void)markerOperationError:(NSError *)error;

- (void)markerOperationSuccessful:(NSDictionary *)data;


@end
