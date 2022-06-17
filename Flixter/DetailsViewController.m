//
//  DetailsViewController.m
//  Flixter
//
//  Created by Rashad Philizaire on 6/16/22.
//

#import "DetailsViewController.h"
#import "TrailerViewController.h"
#import "UIKit+AFNetworking.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieSynopsis;

@property (nonatomic) NSInteger movieId;
@property (nonatomic) NSString *trailerURL;


@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movieTitle.text = self.movie[@"title"];
    self.movieSynopsis.text = self.movie[@"overview"];
    self.movieId = [self.movie[@"id"] integerValue];
    [self.movieSynopsis sizeToFit];
    
    [self setPosterImage];
//    self.posterImage.image = [self getPosterImg];
    self.headerImage.image = [self getBackdropImg];
    
    [self fetchMovieTrailers:^(NSDictionary *dataDictionary) {
        NSDictionary *trailerInfo = (dataDictionary[@"results"])[0];
        NSString *videoId = trailerInfo[@"key"];
        self.trailerURL = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoId];
    } error:^(NSError *error) {
        
    }];
}


- (void)fetchMovieTrailers:(void(^)(NSDictionary *))successCallback error:(void(^)(NSError *))error {
    
    NSString *trailerRequestUrl = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%ld/videos?api_key=5331f8c5e67c10dd976df1090102c873&language=en-US", (long)self.movieId];
    
    NSURL *url = [NSURL URLWithString:trailerRequestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
           if (requestError != nil) {
           }
           else {
           NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               successCallback(dataDictionary);
           }
       }];
    [task resume];
    
}

- (void) setPosterImage {
    if ([self.movie[@"poster_path"] isKindOfClass: [NSString class]]) {
        NSString *posterPath = self.movie[@"poster_path"];
        
        NSString *smallUrl = @"https://image.tmdb.org/t/p/w200/";
        NSString *largeUrl = @"https://image.tmdb.org/t/p/w500/";
        
        NSData *posterData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[largeUrl stringByAppendingString:posterPath]]];
        UIImage *posterImage = [UIImage imageWithData:posterData];
        self.posterImage.image = posterImage;
    }
}

- (void) setBackdropImage {
    if ([self.movie[@"backdrop_path"] isKindOfClass: [NSString class]]) {
        NSString *backdropPath = self.movie[@"backdrop_path"];
        
        NSURL *smallUrl = [NSURL URLWithString:[@"https://image.tmdb.org/t/p/w200/" stringByAppendingString:backdropPath]];
        NSURL *largeUrl = [NSURL URLWithString:[@"https://image.tmdb.org/t/p/w500/" stringByAppendingString:backdropPath]];
        
        NSURLRequest *requestSmall = [NSURLRequest requestWithURL:smallUrl];
        NSURLRequest *requestLarge = [NSURLRequest requestWithURL:largeUrl];
        
        __weak DetailsViewController *weakSelf = self;
        
        [self.posterImage setImageWithURLRequest:requestSmall
            placeholderImage:nil
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
            
            weakSelf.headerImage.alpha = 0.0;
            weakSelf.headerImage.image = smallImage;
            
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.headerImage.alpha = 1.0;
            } completion:^(BOOL finished) {
                [weakSelf.headerImage setImageWithURLRequest:requestLarge
                    placeholderImage:smallImage
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *largeImage) {
                    weakSelf.headerImage.image = largeImage;
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    
                }];
            }];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
           
        }];
        
//        NSData *backdropData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[smallUrl stringByAppendingString:backdropPath]]];
//        UIImage *backdropImage = [UIImage imageWithData:backdropData];
//        self.headerImage.image = backdropImage;
    }
}

- (UIImage *) getPosterImg {
    if ([self.movie[@"poster_path"] isKindOfClass: [NSString class]]) {
        NSString *posterPath = self.movie[@"poster_path"];
        NSString *baseUrl = @"https://image.tmdb.org/t/p/w500/";
        NSData *posterData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[baseUrl stringByAppendingString:posterPath]]];
        UIImage *posterImage = [UIImage imageWithData:posterData];
        return posterImage;
    }
    return nil;
}
- (UIImage *) getBackdropImg {
    if ([self.movie[@"backdrop_path"] isKindOfClass: [NSString class]]) {
        NSString *backdropPath = self.movie[@"backdrop_path"];
        NSString *baseUrl = @"https://image.tmdb.org/t/p/w500/";
        NSData *backdropData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[baseUrl stringByAppendingString:backdropPath]]];
        UIImage *backdropImage = [UIImage imageWithData:backdropData];
        return backdropImage;
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%@", sender);
    TrailerViewController *trailerVC = [segue destinationViewController];
    trailerVC.trailerUrl = self.trailerURL;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
