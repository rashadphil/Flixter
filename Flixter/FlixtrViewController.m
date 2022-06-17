//
//  FlixtrViewController.m
//  Flixter
//
//  Created by Rashad Philizaire on 6/15/22.
//

#import "FlixtrViewController.h"
#import "MovieTableViewCell.h"
#import "DetailsViewController.h"
#import "PosterCell.h"

@interface FlixtrViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *movieArray;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation FlixtrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDateLabel];
    
    // refreshing results
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    
    //setting datasources
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self fetchMovieData:^(NSDictionary *dataDictionary) {
        self.movieArray = dataDictionary[@"results"];
        self.filteredMovies = self.movieArray;
       [self.tableView reloadData];
    } error:^(NSError *error) {
        
    }];
    
}

- (void)setDateLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, MMM dd"];

    //get the date today
    NSString *dateToday = [formatter stringFromDate:[NSDate date]];

    [self.dateLabel setText:[dateToday uppercaseString]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *index = [self.tableView indexPathForCell:sender];
    NSDictionary *movie = self.movieArray[index.row];
    DetailsViewController *detailsVC = [segue destinationViewController];
    detailsVC.movie = movie;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieTableViewCell"];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];

    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    cell.posterImage.image = [FlixtrViewController posterImgFromMovie:movie rowIndex:indexPath.row];
    
    // Change Cell UI
    cell.contentView.layer.borderColor = [[UIColor blackColor] CGColor];
    cell.contentView.layer.borderWidth = 1;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovies.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movieArray filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredMovies = self.movieArray;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
}


- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fetchMovieData:^(NSDictionary *dataDictionary) {
        [self.tableView reloadData];
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
