# Duplicate image finder

This application will search a folder and its sub-folders for duplicate files and move them to a specified location.
Only files within the same folder are considered duplicates!

### Build the application

#### Dependencies

[Install Elixir](http://elixir-lang.org/install.html).

You need the tool [Compare](http://www.imagemagick.org/script/compare.php) from [ImageMagick](http://www.imagemagick.org/). If you are on OS X and have got brew installed, you can install it with:

```
brew install imagemagick
```

#### Compile the application to a binary

```
mix escript.build
```

This will create a binary called "duplicate_image" which you can run on all systems which has the Erlang-runtime installed.

#### Launch the application
```
./duplicate_iamge /path/to/gallery /path/where/to/store/duplicates 0.1
```
The threshold, 0.1 in the example, must be a floating-poing number. 0.0 is a perfect match and 1.0 is entirely different. Perfect matches will always be moved!

### Other
The [metric](http://www.imagemagick.org/script/command-line-options.php#metric) used is "RMSE". The comparison is very slow and CPU-demanding which motivates parallelisation. The number of concurrent Elixir processes will be determined by the Erlang setting "schedulers_online" which normally amounts to the number of CPU-cores (or CPU-cures * 2 if hyper-threading is used).

### License
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
