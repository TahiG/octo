#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CLPlacemark+HNKAdditions.h"
#import "HNKGooglePlacesAutocomplete.h"
#import "HNKGooglePlacesAutocompleteModel.h"
#import "HNKGooglePlacesAutocompletePlace.h"
#import "HNKGooglePlacesAutocompletePlaceSubstring.h"
#import "HNKGooglePlacesAutocompletePlaceTerm.h"
#import "HNKGooglePlacesAutocompleteQuery.h"
#import "HNKGooglePlacesAutocompleteQueryConfig.h"
#import "HNKGooglePlacesAutocompleteQueryResponse.h"
#import "HNKGooglePlacesServer.h"

FOUNDATION_EXPORT double HNKGooglePlacesAutocompleteVersionNumber;
FOUNDATION_EXPORT const unsigned char HNKGooglePlacesAutocompleteVersionString[];

