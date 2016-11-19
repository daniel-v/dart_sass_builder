Before going into details, please read how [build is different](https://github.com/dart-lang/build/) from transformers.
 
## Setting up your project

### Add dependency

```yaml
dev_dependencies:
  sass_builder:
    git: https://github.com/daniel-v/dart_sass_builder.git
```

### Set up build phase

The convention I follow:

* have `tool` folder
* have a `tool\build.dart` file that contains all the build phases, Sass compilation is one of them

### Specify SASS file locations

In the [build file](tool/build.dart), specify what where you sass files are:

```dart
SassBuilder.addPhases(phases, graph, ['lib/**/*.scss']);
```

### Run builder

```bash
pub run tool/build.dart && pub serve
```

You can now open your browser at `http://localhost:8080/`

