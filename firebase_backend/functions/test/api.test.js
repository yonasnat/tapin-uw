const admin = require('firebase-admin');
const functions = require('firebase-functions-test')();

// Mock Firebase Admin
jest.mock('firebase-admin', () => ({
  auth: () => ({
    getUserByEmail: jest.fn(),
    createUser: jest.fn(),
    updateUser: jest.fn(),
    deleteUser: jest.fn(),
  }),
  firestore: () => ({
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        set: jest.fn(),
        get: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      })),
    })),
  }),
}));

describe('API Tests', () => {
  let adminInitStub;

  beforeAll(() => {
    adminInitStub = jest.spyOn(admin, 'initializeApp');
  });

  afterAll(() => {
    adminInitStub.mockRestore();
    functions.cleanup();
  });

  describe('Login API', () => {
    test('should successfully login with valid credentials', async () => {
      // Mock successful login
      const mockUser = {
        uid: 'test-uid',
        email: 'test@uw.edu',
        emailVerified: true,
      };

      admin.auth().getUserByEmail.mockResolvedValueOnce(mockUser);

      // Simulate login request
      const req = {
        body: {
          email: 'test@uw.edu',
          password: 'validPassword123',
        },
      };

      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      // Call the login function (you'll need to import your actual login function)
      // await loginFunction(req, res);

      // Assertions
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        success: true,
        user: expect.objectContaining({
          uid: 'test-uid',
          email: 'test@uw.edu',
        }),
      }));
    });

    test('should fail login with invalid credentials', async () => {
      // Mock failed login
      admin.auth().getUserByEmail.mockRejectedValueOnce(new Error('Invalid credentials'));

      // Simulate login request with invalid credentials
      const req = {
        body: {
          email: 'test@uw.edu',
          password: 'wrongPassword',
        },
      };

      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      // Call the login function (you'll need to import your actual login function)
      // await loginFunction(req, res);

      // Assertions
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        success: false,
        error: 'Invalid credentials',
      }));
    });
  });
}); 