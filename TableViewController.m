//
//  TableViewController.m
//  XMLParseProgress
//
//  Created by 達郎 植田 on 12/07/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+GIF.h"
#import "AFJSONRequestOperation.h"

const NSString *kStrJsonURL = @"http://protected-oasis-1115.herokuapp.com/";

@interface TableViewController ()

@end

@implementation TableViewController
@synthesize itemsArray = _itemsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// リストテーブルのアイテム数を返すメソッド
// 「UITableViewDataSource」プロトコルの必須メソッド
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_JSON valueForKeyPath:@"rss.channel.item.title"] count];
}

// リストテーブルに表示するセルを返すメソッド
// 「UITableViewDataSource」プロトコルの必須メソッド
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    // 範囲チェックを行う
    if (indexPath.row < [[_JSON valueForKeyPath:@"rss.channel.item.title"] count]) {
        
        // セルを作成する
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        NSString *s = 
        [[_JSON valueForKeyPath:@"rss.channel.item.link"] objectAtIndex:indexPath.row];

        // ローディングの画像をとりあえず表示する
        cell.imageView.image = [UIImage animatedGIFNamed:@"loading3"];

        // og:imageのURLを取得するには時間がかかるので、別スレッドを立てる
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
            NSURL *urlOgImage = [self ogImageURLWithURL:[NSURL URLWithString:s]];
            
            // og:imageのURLを確認した後でメインスレッドに戻す
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                if (urlOgImage != nil) {
                    UIImage* image = [UIImage animatedGIFNamed:@"loading3"];
                    [cell.imageView setImageWithURL:urlOgImage
                                   placeholderImage:image];
                }
                else {
                    UIImage *noImage = [UIImage imageNamed:@"noImage.png"];
                    cell.imageView.image = noImage;
                }
            }];
        }];
                
        cell.textLabel.text = 
        [[_JSON valueForKeyPath:@"rss.channel.item.title"] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text =
        [[_JSON valueForKeyPath:@"rss.channel.item.description"] objectAtIndex:indexPath.row];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)refresh:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"読み込んでいます"
                                                        message:nil//@"\n\n"
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                              otherButtonTitles:nil];
//    _progressView = [[UIProgressView alloc]
//                     initWithFrame:CGRectMake(30.0f, 60.0f, 225.0f, 90.0f)];
    [alertView addSubview:_progressView];
//    [_progressView setProgressViewStyle: UIProgressViewStyleBar];
    [alertView show];
    
    // JSONを取得する
    NSURL *url = [NSURL URLWithString:kStrJsonURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id getJSON) {
        _JSON = getJSON;
        NSLog(@"%@", _JSON);
        
        // JSONを取得し終わったらアラートビューを閉じてテーブルを更新する
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self.tableView reloadData];
    } failure:nil];
    [operation start];        
}

- (NSURL *)ogImageURLWithURL:(NSURL *)url
{
    NSString *string = [self encodedStringWithContentsOfURL:url];    
    
    // prepare regular expression to find text
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:
     @"<meta property=\"og:image\" content=\".+\""
                                              options:0
                                                error:&error];
    
    // find by regular expression
    NSTextCheckingResult *match =
    [regexp firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    
    // get the first result
    NSRange resultRange = [match rangeAtIndex:0];
//    NSLog(@"match=%@", [string substringWithRange:resultRange]); 
    
    if (match) {
        
        // get the og:image URL from the find result
        NSRange urlRange = NSMakeRange(resultRange.location + 35, resultRange.length - 35 - 1);
        NSURL *urlOgImage = [NSURL URLWithString:[string substringWithRange:urlRange]];
        return urlOgImage;
    }
    return nil;
}

- (NSString *)encodedStringWithContentsOfURL:(NSURL *)url
{
    // Get the web page HTML
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // response
    int enc_arr[] = {
        NSUTF8StringEncoding,           // UTF-8
        NSShiftJISStringEncoding,       // Shift_JIS
        NSJapaneseEUCStringEncoding,    // EUC-JP
        NSISO2022JPStringEncoding,      // JIS
        NSUnicodeStringEncoding,        // Unicode
        NSASCIIStringEncoding           // ASCII
    };
    NSString *data_str = nil;
    int max = sizeof(enc_arr) / sizeof(enc_arr[0]);
    for (int i=0; i<max; i++) {
        data_str = [
                    [NSString alloc]
                    initWithData : data
                    encoding : enc_arr[i]
                    ];
        if (data_str!=nil) {
            break;
        }
    }
    return data_str;    
}

@end
