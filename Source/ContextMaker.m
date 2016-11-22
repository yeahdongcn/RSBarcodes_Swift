//
//  ContextMaker.m
//  RSBarcodes
//
//  Created by R0CKSTAR on 11/22/16.
//  Copyright (c) 2016 P.D.Q. All rights reserved.
//

#import "ContextMaker.h"

@implementation ContextMaker

+ (CIContext*) make
{
   return [CIContext contextWithOptions:nil];
}

@end
