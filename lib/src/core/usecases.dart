import 'package:dartz/dartz.dart';
import 'package:tracker_test/src/core/failures.dart';

abstract class UseCase<Type, Params> {
  Either<Failure, Type> call(Params params);
}

abstract class FutureUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams{
  
}

