import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../utils/base_repository.dart';


class Paginator<T extends BaseRestRepository, K> with ChangeNotifier {
  T repo;
  Map<String, dynamic> _params;
  List<K> _items;
  bool loadingIsFailed = false;

  Paginator();
  Paginator.withRepo(this.repo);

  bool get isEnd => false;
  UnmodifiableListView<K> get items => UnmodifiableListView(_items);

  setRepo(T repo) {
    this.repo = repo;
  }

  setParams(Map<String, dynamic> params) {
    _params = params;
    _items?.clear();
  }

  reset() {
    _params = null;
    _items?.clear();
  }

  Future<List<K>> fetchNext() async {
    var pair = await repo.getList(params: _params);
    return pair.result;
  }
}


class LimitOffsetPaginator<T, K> extends Paginator {
  int currentOffset = 0;
  int limit = 25;
  int count;

  LimitOffsetPaginator.withRepo(repo) : super.withRepo(repo);

  @override
  bool get isEnd {
    return count != null && (currentOffset + limit) >= count;
  }

  @override
  setParams(Map<String, dynamic> params) {
    super.setParams(params);
    count = null;
    currentOffset = 0;

    if (_params != null) {
      _params['limit'] = limit;
    }
  }

  @override
  reset() {
    super.reset();
    count = null;
    currentOffset = 0;
  }

  @override
  Future<List<K>> fetchNext() async {
    if (_params == null) {  // еще не скачали первую страницу
      currentOffset = 0;
      _params = {
        'limit': limit,
        'offset': 0,
      };
    } else {
      currentOffset += limit;
      _params['offset'] = currentOffset;
    }

    loadingIsFailed = false;

    ResultAndMeta<dynamic> pair;
    try {
      pair = await repo.getList(params: _params);
    } catch (e) {
      loadingIsFailed = true;
      return null;
    }

    count = pair.meta == null ? pair.result.length : pair.meta['count'];
    if (_items == null) {
      _items = pair.result;
    } else {
      _items.addAll(pair.result);
    }
    return pair.result;
  }
}
