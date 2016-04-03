// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

const int SETTLEMENT_PRODUCTION = 1;

class Settlement extends Building {
  Settlement(int key) : super(key, SETTLEMENT_PRODUCTION);
}
