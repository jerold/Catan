// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

const int CITY_PRODUCTION = 2;

class City extends Building {
  City(int key) : super(key, CITY_PRODUCTION);
}
