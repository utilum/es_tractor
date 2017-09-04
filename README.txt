# @markup markdown
# EsTractor: Simplified data extracton from Elasticsearch

[[Home]](https://github.com/utilum/es_tractor)

## DESCRIPTION:

Sub-set of Search APIs with DRY query building.

## FEATURES/PROBLEMS:

- Subset of Search APIs: count, search.
- Minimal DRY query builder maps root elements of a Hash argument into boolean
  filters.

- TODO:
  - Add Search APIs:
      - Fields
      - Sort
      - Scroll
  - Aggregations
  - Report formats: CSV, JSON.
  - Extraction: Aggregation to flat records (separate project?).

## SYNOPSIS:

```
include EsTractor
tractor = Client.new

tractor.count
  # => (Integer) number of documents on the server

tractor.count(term: { my_field: 'my precise term' })
  # => (Integer) number of documents where my_field == 'my precise term'
```

## REQUIREMENTS:

Some environment variables are expected:
- L2B_ELASTICSEARCH_HOST
- L2B_ELASTICSEARCH_INDEX

## DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## LICENSE:

(The MIT License)

Copyright (c) 2017 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
