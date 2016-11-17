//
//  MarkerOperation.h
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarkerOperationDelegate.h"

@interface MarkerOperation : NSObject
{
    id <MarkerOperationDelegate> delegate;
}

@property (retain) id <MarkerOperationDelegate> _Nonnull delegate;


#pragma mark - Class Lifecycle Methods

- (id _Nullable) init __unavailable;

- (id _Nullable) initWithDelegate:(id <MarkerOperationDelegate> _Nonnull)delegate;


#pragma mark - Methods

- (void) getDataFromLocalFile;

@end
