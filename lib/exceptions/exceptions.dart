// represents communication error between client and server
class CommunicationException implements Exception
{}

// represents an error sue to conflicts on server, like email taken
class ConflictException implements Exception
{}

// represents incorrect username and password
class AuthenticationException implements Exception
{}

// represents that book is not found
class BookNotFoundException implements Exception
{}

// represents that the user is forbidden to access the resource, like updating someone else's book
class ForbiddenException implements Exception
{}