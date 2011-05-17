
#import "Workspace.h"
#import "Project.h"


static Workspace *sharedWorkspace;


@implementation Workspace

@synthesize projects=_projects;


#pragma mark -
#pragma mark Singleton

+ (Workspace *)sharedWorkspace {
    if (sharedWorkspace == nil) {
        sharedWorkspace = [[Workspace alloc] init];
    }
    return sharedWorkspace;
}


#pragma mark -
#pragma mark Init/dealloc

- (id)init {
    if ((self = [super init])) {
        _projects = [[NSMutableSet alloc] init];

        // temporary projects for debugging, until we implement persistence
        [self addProjectsObject:[[[Project alloc] initWithPath:@"/Users/andreyvit/Dropbox"] autorelease]];
    }
    return self;
}

// just to make XDry happy; won't ever be deallocated
- (void)dealloc {
    [_projects release], _projects = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Projects set KVC accessors

- (void)addProjectsObject:(Project *)project {
    NSParameterAssert(![_projects containsObject:project]);
    [_projects addObject:project];
    if (_monitoringEnabled) {
        project.monitoringEnabled = YES;
    }
}

- (void)removeProjectsObject:(Project *)project {
    NSParameterAssert([_projects containsObject:project]);
    project.monitoringEnabled = NO;
    [_projects removeObject:project];
}

- (NSArray *)sortedProjects {
    return [[self.projects allObjects] sortedArrayUsingSelector:@selector(path)];
}


#pragma mark -
#pragma mark File System Monitoring

- (BOOL)isMonitoringEnabled {
    return _monitoringEnabled;
}

- (void)setMonitoringEnabled:(BOOL)shouldMonitor {
    if (_monitoringEnabled != shouldMonitor) {
        _monitoringEnabled = shouldMonitor;
        for (Project *project in _projects) {
            project.monitoringEnabled = _monitoringEnabled;
        }
    }
}


@end
