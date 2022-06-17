//
//  GridViewController.m
//  Flixter
//
//  Created by Rashad Philizaire on 6/16/22.
//

#import "GridViewController.h"
#import "PosterCell.h"
#import "DetailsViewController.h"

@interface GridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@property (nonatomic, strong) NSArray *movieArray;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //refreshing results
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.gridView insertSubview:refreshControl atIndex:0];
    
    //setting datasources
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    
    [self fetchMovieData:^(NSDictionary *dataDictionary) {
        self.movieArray = dataDictionary[@"results"];
       [self.gridView reloadData];
    } error:^(NSError *error) {
        
    }];
}
    
- (void)fetchMovieData:(void(^)(NSDictionary *))successCallback error:(void(^)(NSError *))error {
    [self.activityIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=5331f8c5e67c10dd976df1090102c873"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
           if (requestError != nil) {
               
               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Load Movies" message:@"The internet connection appears to be offline." preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                   [self viewDidLoad];
                   
               }];
               
               [alert addAction:defaultAction];
               [self presentViewController:alert animated:YES completion:nil];
           }
           else {
           NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               successCallback(dataDictionary);
               [self.activityIndicator stopAnimating];
           }
       }];
    [task resume];
}

+ (UIImage *) posterImgFromMovie:(NSDictionary *)movie rowIndex:(NSInteger)index {
    if ([movie[@"poster_path"] isKindOfClass: [NSString class]]) {
        NSString *posterPath = movie[@"poster_path"];
        NSString *baseUrl = @"https://image.tmdb.org/t/p/w500/";
        NSData *posterData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[baseUrl stringByAppendingString:posterPath]]];
        UIImage *posterImage = [UIImage imageWithData:posterData];
        return posterImage;
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *index = [self.gridView indexPathForCell:sender];
    NSDictionary *movie = self.movieArray[index.row];
    DetailsViewController *detailsVC = [segue destinationViewController];
    detailsVC.movie = movie;
}



- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movieArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    PosterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PosterCell" forIndexPath:indexPath];

    NSDictionary *movie = self.movieArray[indexPath.row];
    cell.posterImg.image = [GridViewController posterImgFromMovie:movie rowIndex:indexPath.row];

    return cell;
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchMovieData:^(NSDictionary *dataDictionary) {
        [self.gridView reloadData];
        [refreshControl endRefreshing];
    } error:^(NSError *error) {
            
    }];
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
     
     
     
