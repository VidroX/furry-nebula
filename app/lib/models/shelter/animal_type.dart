import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/translations.dart';

enum AnimalType {
  cat,
  dog,
  bird,
  rabbit;

  static AnimalType? fromGAnimal(GAnimal animal) => {
    GAnimal.Cat: cat,
    GAnimal.Dog: dog,
    GAnimal.Bird: bird,
    GAnimal.Rabbit: rabbit,
  }[animal];

  GAnimal get toGAnimal => {
    cat: GAnimal.Cat,
    dog: GAnimal.Dog,
    bird: GAnimal.Bird,
    rabbit: GAnimal.Rabbit,
  }[this]!;

  String get translationKey => {
    cat: Translations.animalTypesCat,
    dog: Translations.animalTypesDog,
    bird: Translations.animalTypesBird,
    rabbit: Translations.animalTypesRabbit,
  }[this]!;
}
