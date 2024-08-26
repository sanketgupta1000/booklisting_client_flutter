// represents communication error between client and server
class CommunicationException implements Exception
{}

// represents an error sue to conflicts on server, like email taken
class ConflictException implements Exception
{}

// represents incorrect username and password
class AuthenticationException implements Exception
{}