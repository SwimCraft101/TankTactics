// StockfishBridge.mm
#import "StockfishBridge.h"

#include <iostream>
#include <sstream>
#include <thread>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <memory>

// Stockfish 18 Headers based on main.cpp
#include "bitboard.h"
#include "position.h"
#include "ucioption.h"
#include "tune.h"
#include "misc.h" // or wherever CommandLine is defined in SF 18
#include "uci.h"         // provides UCIEngine

using namespace Stockfish;

// Stream buffer to intercept output from std::cout -> Swift/ObjC
class InterceptStreamBuf : public std::streambuf {
private:
    std::string buffer;
    StockfishOutputBlock outputBlock;

protected:
    virtual int overflow(int c) override {
        if (c != EOF) {
            char ch = static_cast<char>(c);
            if (ch == '\n') {
                NSString *line = [NSString stringWithUTF8String:buffer.c_str()];
                if (line && outputBlock) {
                    outputBlock(line);
                }
                buffer.clear();
            } else {
                buffer += ch;
            }
        }
        return c;
    }

public:
    InterceptStreamBuf(StockfishOutputBlock handler) : outputBlock(handler) {}
};

// Custom streambuf to feed Swift commands into std::cin
class InputPipeStreamBuf : public std::streambuf {
private:
    std::queue<std::string> &queue;
    std::mutex &mutex;
    std::condition_variable &cv;
    bool &isRunning;
    std::string currentLine;
    size_t readPos;

protected:
    virtual int uflow() override {
        if (readPos < currentLine.size()) {
            return static_cast<unsigned char>(currentLine[readPos++]);
        }
        
        std::unique_lock<std::mutex> lock(mutex);
        cv.wait(lock, [this] { return !queue.empty() || !isRunning; });
        
        if (!isRunning && queue.empty()) {
            return EOF;
        }
        
        currentLine = queue.front() + "\n";
        queue.pop();
        readPos = 0;
        
        return static_cast<unsigned char>(currentLine[readPos++]);
    }

    virtual int underflow() override {
        int c = uflow();
        if (c != EOF) {
            readPos--; // Unget so underflow doesn't consume
        }
        return c;
    }

public:
    InputPipeStreamBuf(std::queue<std::string> &q, std::mutex &m, std::condition_variable &c, bool &r)
        : queue(q), mutex(m), cv(c), isRunning(r), readPos(0) {}
};

@implementation StockfishBridge {
    std::streambuf *oldCoutBuf;
    std::streambuf *oldCinBuf;
    InterceptStreamBuf *interceptBuf;
    InputPipeStreamBuf *inputBuf;
    
    std::thread engineThread;
    std::queue<std::string> commandQueue;
    std::mutex queueMutex;
    std::condition_variable queueCV;
    bool isRunning;
}

- (instancetype)initWithOutputHandler:(StockfishOutputBlock)outputHandler {
    self = [super init];
    if (self) {
        isRunning = true;
        
        // 1. Redirect std::cout (Engine -> Swift)
        interceptBuf = new InterceptStreamBuf(outputHandler);
        oldCoutBuf = std::cout.rdbuf(interceptBuf);
        
        // 2. Redirect std::cin (Swift -> Engine)
        inputBuf = new InputPipeStreamBuf(commandQueue, queueMutex, queueCV, isRunning);
        oldCinBuf = std::cin.rdbuf(inputBuf);
        
        // 3. Launch processing thread
        engineThread = std::thread([self]() {
            [self runEngineLoop];
        });
    }
    return self;
}

- (void)sendCommand:(NSString *)command {
    std::string cmd = [command UTF8String];
    {
        std::lock_guard<std::mutex> lock(queueMutex);
        commandQueue.push(cmd);
    }
    queueCV.notify_one();
}

- (void)runEngineLoop {
    char progName[] = "stockfish";
    char* argv[] = { progName, nullptr };
    int argc = 1;

    // 1. Initialize Stockfish 18 tables
    Stockfish::Attacks::init();
    Stockfish::Position::init();

    // 2. Instantiate CommandLine and UCIEngine (matching main.cpp)
    auto cli = Stockfish::CommandLine(argc, argv);
    auto uci = std::make_unique<Stockfish::UCIEngine>(std::move(cli));

    // 3. Initialize Tuning options
    Stockfish::Tune::init(uci->engine_options());

    // 4. Run the UCI loop (reads from redirected std::cin, prints to redirected std::cout)
    uci->loop();
}

- (void)stop {
    {
        std::lock_guard<std::mutex> lock(queueMutex);
        isRunning = false;
        commandQueue.push("quit"); // Instruct Stockfish loop to exit
    }
    queueCV.notify_all();
    
    if (engineThread.joinable()) {
        engineThread.join();
    }
    
    // Restore original std streams
    if (oldCoutBuf) {
        std::cout.rdbuf(oldCoutBuf);
        delete interceptBuf;
        oldCoutBuf = nullptr;
    }
    
    if (oldCinBuf) {
        std::cin.rdbuf(oldCinBuf);
        delete inputBuf;
        oldCinBuf = nullptr;
    }
}

- (void)dealloc {
    [self stop];
}

- (NSArray<NSString *> *)legalMovesForFEN:(NSString *)fen {
    std::string fenStr = [fen UTF8String];
    
    // Initialize standard Stockfish objects
    Stockfish::StateInfo state;
    Stockfish::Position pos;
    
    // Parse FEN string into Stockfish Position
    pos.set(fenStr, false, &state);
    
    NSMutableArray<NSString *> *moves = [NSMutableArray array];
    
    return moves;
}

@end
