//
//  CustomAnnotationPoint.h
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Mapbox;

@interface CustomAnnotationPoint : NSObject <MGLAnnotation>
{
    NSString * hyperlink;
    
    NSString * imageURL;
}

// As a reimplementation of the MGLAnnotation protocol, we have to add mutable coordinate and (sub)title properties ourselves.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, nullable) NSString * title;

@property (nonatomic, copy, nullable) NSString * subtitle;

@property (nonatomic, copy, nonnull) NSString * reuseIdentifier;


# pragma mark - Additional properties
// Custom properties that we will use to customize the annotation.

@property (nonatomic, copy, nonnull) NSString * hyperlink;

@property (nonatomic, copy, nonnull) NSString * imageURL;

@end
