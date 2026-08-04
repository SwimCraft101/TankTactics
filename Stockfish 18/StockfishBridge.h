//
//  StockfishBridge.h
//  TankTactics
//
//  Created by Hilton Sherrard on 8/2/26.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^StockfishOutputBlock)(NSString *outputLine);

@interface StockfishBridge : NSObject

/// Initialize the C++ engine instance and output interceptor
- (instancetype)initWithOutputHandler:(StockfishOutputBlock)outputHandler;

/// Send a UCI command string (e.g., "position startpos", "go depth 15")
- (void)sendCommand:(NSString *)command;

/// Terminate the engine loop
- (void)stop;

/// Returns an array of legal UCI move strings for a given FEN string
- (NSArray<NSString *> *)legalMovesForFEN:(NSString *)fen;

@end

NS_ASSUME_NONNULL_END
