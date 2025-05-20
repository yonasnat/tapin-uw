// Mock data
const mockUid = 'test-user-123';
const mockFilters = {
  ageRange: { min: 18, max: 30 },
  distance: 50,
  interests: ['sports', 'music']
};

// Mock Firestore
const mockDb = {
  collection: jest.fn().mockReturnThis(),
  doc: jest.fn().mockReturnThis(),
  set: jest.fn().mockResolvedValue(),
  get: jest.fn().mockResolvedValue({
    exists: true,
    data: () => ({
      filters: mockFilters,
      filtersUpdatedAt: new Date()
    })
  }),
  update: jest.fn().mockResolvedValue()
};

// Fix: Mock admin.firestore so FieldValue is accessible as admin.firestore.FieldValue
const mockFieldValue = {
  serverTimestamp: jest.fn(() => new Date()),
  delete: jest.fn(() => 'deleted')
};

jest.mock('firebase-admin', () => {
  const firestoreFn = Object.assign(
    () => mockDb,
    { FieldValue: mockFieldValue }
  );
  return {
    initializeApp: jest.fn(),
    firestore: firestoreFn
  };
});

const admin = require('firebase-admin');
const test = require('firebase-functions-test')();
const matchmakingFilters = require('./matchmakingFilters');

// Wrap the functions for testing
const wrappedSaveUserFilters = test.wrap(matchmakingFilters.saveUserFilters);
const wrappedGetUserFilters = test.wrap(matchmakingFilters.getUserFilters);
const wrappedClearUserFilters = test.wrap(matchmakingFilters.clearUserFilters);

// Mock context
const mockContext = {
  auth: {
    uid: mockUid
  }
};

describe('Matchmaking Filters Functions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterAll(() => {
    test.cleanup();
  });

  describe('saveUserFilters', () => {
    it('should save user filters successfully', async () => {
      const result = await wrappedSaveUserFilters(
        { filters: mockFilters },
        mockContext
      );

      expect(result.status).toBe('success');
      expect(result.savedAt).toBeDefined();
      expect(mockDb.set).toHaveBeenCalledWith(
        {
          filters: mockFilters,
          filtersUpdatedAt: expect.any(Object)
        },
        { merge: true }
      );
    });

    it('should throw error for unauthenticated users', async () => {
      await expect(
        wrappedSaveUserFilters(
          { filters: mockFilters },
          { auth: null }
        )
      ).rejects.toThrow('Only authenticated users can save filters.');
    });

    it('should throw error for invalid filters', async () => {
      await expect(
        wrappedSaveUserFilters(
          { filters: [] },
          mockContext
        )
      ).rejects.toThrow('Filters must be an object mapping filter keys to values.');
    });
  });

  describe('getUserFilters', () => {
    it('should retrieve user filters successfully', async () => {
      const result = await wrappedGetUserFilters({}, mockContext);

      expect(result.filters).toEqual(mockFilters);
      expect(result.filtersUpdatedAt).toBeDefined();
    });

    it('should return null for non-existent user', async () => {
      mockDb.get.mockResolvedValueOnce({ exists: false });

      const result = await wrappedGetUserFilters({}, mockContext);

      expect(result.filters).toBeNull();
      expect(result.filtersUpdatedAt).toBeNull();
    });

    it('should throw error for unauthenticated users', async () => {
      await expect(
        wrappedGetUserFilters({}, { auth: null })
      ).rejects.toThrow('Must be signed in to retrieve filters.');
    });
  });

  describe('clearUserFilters', () => {
    it('should clear user filters successfully', async () => {
      const result = await wrappedClearUserFilters({}, mockContext);

      expect(result.status).toBe('cleared');
      expect(result.clearedAt).toBeDefined();
      expect(mockDb.update).toHaveBeenCalledWith({
        filters: 'deleted',
        filtersUpdatedAt: expect.any(Object)
      });
    });

    it('should throw error for unauthenticated users', async () => {
      await expect(
        wrappedClearUserFilters({}, { auth: null })
      ).rejects.toThrow('Must be signed in to clear filters.');
    });
  });
}); 