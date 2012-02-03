// Copyright yutopp 2012.
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

#library( "rart" );

//----- Iterators -----
interface SimpleIterator<E> extends Iterator<E>/*ugg*/ {
  clone();
  /*operator equals*/
  bool operator==( it );
  int distance( it );
}

//referencable
interface ReferencableIterator<E> extends SimpleIterator<E> {
  E reference();
}

//forward
interface ForwardIterator<E> extends ReferencableIterator<E>
{
  bool hasNext();
  E next(); 
  operator +( int i );
}

//bidirectional
interface BidirectionalIterator<E> extends ForwardIterator<E>
{
  bool hasPrev();
  E prev();
  operator -( int i );
}

//random access
interface RandomAccessIterator<E> extends BidirectionalIterator<E>
{
  E operator[]( elem );
}


//----- Iterable Interface -----
interface SampleIterable<E> {
  ForwardIterator<E> iterator();
  
  ForwardIterator<E> begin();
  ForwardIterator<E> end();
  
  int get length();
}

interface ReverseIterable<E> extends SampleIterable<E> {
  ForwardIterator<E> reverseIterator();
  
  ForwardIterator<E> rbegin();
  ForwardIterator<E> rend();
}



//------- Hobby Range -------
//----- Adaptor Interface -----
interface RangeAdaptor<T>
{
  apply( begin, end );
}

//----- Adaptable Interface -----
interface Adaptable<T> {
  operator |( RangeAdaptor<T> adaptor );
}



//----- Reversed Adaptor -----
class ReverseIterator<T> implements BidirectionalIterator<T>
{
  ReverseIterator( BidirectionalIterator<T> this._it );
  
  clone()
    => new ReverseIterator( _it.clone() );
  
  bool hasNext() => _it.hasPrev();

  T next() => _it.prev();
  
  bool hasPrev() => _it.hasNext();

  T prev() => _it.next();
  
  T reference() => _it.reference();
  
  operator +( int i ) => new ReverseIterator( ( i < -1 || i > 1 ) ? null : _it - i );
  operator -( int i ) => this + -i;
  
  bool operator==( ReverseIterator<T> rhs ) => _it == rhs._it;
  
  int distance( ReverseIterator<T> it ) => _it.distance( it._it );
  
  final BidirectionalIterator<T> _it;
}

class ReversedRangeAdaptor<T> implements RangeAdaptor<T>
{
  apply( BidirectionalIterator<T> begin, BidirectionalIterator<T> end ) {
    return new Range( new ReverseIterator( end - 1 ), new ReverseIterator( begin - 1 ) );
  }
}
reversed() => new ReversedRangeAdaptor();



//----- Filtered Adaptor -----
class FiltereIterator<T> implements BidirectionalIterator<T>
{
  FiltereIterator( BidirectionalIterator<T> this._it, BidirectionalIterator<T> this._end, this._pred );
  
  clone()
    => new FiltereIterator( _it.clone(), _end, _pred );
  
  bool hasNext() {
    final temp = _it.clone();
    while( temp.hasNext() ) {
      if ( temp == _end )
        break;
      if ( _pred( temp.next() ) )
        return true;
    }
    return false;
  }

  T next() {
    while( _it.hasNext() ) {
      final temp = _it.next();
      if ( _pred( temp ) )
        return temp;
    }
    throw const NoMoreElementsException();
  }
  
  bool hasPrev() {
    final temp = _it.clone();
    while( temp.hasPrev() ) {
      if ( temp == _end )
        break;
      if ( _pred( temp.prev() ) )
        return true;
    }
    return false;   
  }

  T prev() {
    while( _it.hasPrev() ) {
      final temp = _it.prev();
      if ( _pred( temp ) )
        return temp;
    }
    throw const NoMoreElementsException();
  }
  
  T reference() => _it.reference();
  
  operator +( int i ) => new FiltereIterator( _it + i, _end + i, _pred );
  operator -( int i ) => this + -i;
  
  bool operator==( final FiltereIterator<T> rhs ) => _it == rhs._it;
  int distance( FiltereIterator<T> it ) {
    int d = 0;
    for( final tmp = _it.clone(); tmp.hasPrev(); ) {
      if ( !_pred( tmp.prev() ) )
        continue;
      
      ++d;
      if ( tmp == it._it )
        return d;
    }
    
    d = 0;
    for( final tmp = _it.clone(); tmp.hasNext(); ) {
      if ( !_pred( tmp.next() ) )
        continue;
      
      ++d;
      if ( tmp == it._it )
        break;
    }
    
    return d;
  }
  
  final BidirectionalIterator<T> _it, _end;
  final _pred;
}

class FilteredRangeAdaptor<T> implements RangeAdaptor<T>
{
  FilteredRangeAdaptor( this._pred );
  
  apply( BidirectionalIterator<T> begin, BidirectionalIterator<T> end ) {
    return new Range( new FiltereIterator( begin, end, _pred ), new FiltereIterator( end, begin, _pred ) );
  }
  
  final _pred;
}
filtered( pred ) => new FilteredRangeAdaptor( pred );



//----- Transformed Adaptor -----
class TransformIterator<T> implements BidirectionalIterator<T>
{
  TransformIterator( BidirectionalIterator<T> this._it, this._f );
  
  clone()
    => new TransformIterator( _it.clone(), _f );
  
  bool hasNext() => _it.hasNext();
  T next() => _f( _it.next() );
  
  bool hasPrev() => _it.hasPrev();
  T prev()  => _f( _it.prev() );
  
  T reference() => _f( _it.reference() );
  
  operator +( int i ) => new TransformIterator( _it + i, _f );
  operator -( int i ) => this + -i;
  
  bool operator==( TransformIterator<T> rhs ) => _it == rhs._it;
  
  int distance( TransformIterator<T> it ) => _it.distance( it._it );
  
  final BidirectionalIterator<T> _it;
  final _f;
}

class TransformedRangeAdaptor<T> implements RangeAdaptor<T>
{
  TransformedRangeAdaptor( this._f );
  
  apply( BidirectionalIterator<T> begin, BidirectionalIterator<T> end ) {
    return new Range( new TransformIterator( begin, _f ), new TransformIterator( end, _f ) );
  }
  
  final _f;
}
transformed( f ) => new TransformedRangeAdaptor( f );



//----- Replaced If Adaptor -----
class ReplacedIfRangeAdaptor<T> implements RangeAdaptor<T>
{
  ReplacedIfRangeAdaptor( this._pred, this._dst );
  
  apply( BidirectionalIterator<T> begin, BidirectionalIterator<T> end ) {
    final f = (v) => _pred(v) ? _dst : v;
    return new Range( new TransformIterator( begin, f ), new TransformIterator( end, f ) );
  }
  
  final _pred;
  final _dst;
}
replaced_if( pred, dst ) => new ReplacedIfRangeAdaptor( pred, dst );



//----- Replaced Adaptor -----
replaced( src, dst ) => new ReplacedIfRangeAdaptor( (v)=> v == src, dst );



//----- Sliced Adaptor -----
class SlicedRangeAdaptor<T> implements RangeAdaptor<T>
{
  SlicedRangeAdaptor( int this._n, int this._m );
  
  apply( ForwardIterator<T> begin, final ForwardIterator<T> end ) { 
    for( int i=0; i<_n; ++i ) {
      if ( begin == end )
        throw const NoMoreElementsException();
      begin.next();
    }
    
    final int dist = _m - _n;
    if ( dist < 0 )
      throw const IllegalArgumentException();
    
    ForwardIterator<T> tmp = begin.clone();
    for( int i=0; i<dist; ++i ) {
      if ( tmp == end )
        throw const NoMoreElementsException();
      tmp.next();
    }
    
    return new Range( begin, tmp );
  }
  
  final int _n, _m;
}
sliced( int n, int m ) => new SlicedRangeAdaptor( n, m );



//----- Joined Adaptor -----
class JoinIterator<T> implements BidirectionalIterator<T>
{
  JoinIterator( BidirectionalIterator<T> this._first, BidirectionalIterator<T> this._second, [bool this._is_first = true] );
  
  clone()
    => new JoinIterator( _first.clone(), _second.clone(), _is_first );
  
  bool hasNext() {
    if ( _is_first )
      if ( _first.hasNext() )
        return true;
 
/*    if ( !_second.hasPrev() )
      _second = _second + 1;*/
    
    _is_first = false;
    return _second.hasNext();
  }

  T next() {
    if ( !hasNext() )
      return null;
    return ( _is_first ) ? _first.next() : _second.next();
  }
  
  bool hasPrev() {  
    if ( !_is_first )
      if ( _second.hasPrev() )
        return true;
    
    if ( !_first.hasNext() )
      _first = _first - 1;

    _is_first = true;
    return _first.hasPrev();
  }

  T prev() {
    if ( !hasPrev() )
      return null;
    
    return ( _is_first ) ? _first.prev() : _second.prev();
  }
  
  T reference() => _is_first ? _first.reference() : _second.reference();
  
  operator +( int i ) {
    if ( i < 0 )
      return this - -i;
    if ( i > 1 )
      return null; 
    
    final bool b = _first.hasNext();
    return new JoinIterator( b ? _first + i : _first, !b ? _second + i : _second, (_first + 1).hasNext() );
  }
    
  operator -( int i ) {
    if ( i < 0 )
      return this + -i;
    if ( i > 1 )
      return null;
    
    final bool b = !( _second - 1 ).hasPrev();
    return new JoinIterator( b ? _first - i : _first, !b ? _second - i : _second, b );
  }
  
  bool operator==( JoinIterator<T> rhs )
    => ( _is_first == rhs._is_first ) && ( _is_first ? _first == rhs._first : _second == rhs._second );
  
  int distance( JoinIterator<T> it ) {
    int d = 0;
    if ( _is_first ) {
      d += _first.distance( it._first );
      if ( !it._is_first )
        d += _second.distance( it._second );
      
    } else {
      d += _second.distance( it._second );
      if ( it._is_first )
        d += _first.distance( it._first );
    }
    return d;
  }
    
  BidirectionalIterator<T> _first, _second;
  bool _is_first;
}

join( rng1, rng2 )
  => new Range(
    new JoinIterator( rng1.begin(), rng2.begin() ),
    new JoinIterator( rng1.end()/* - 1*/, rng2.end(), false )
    );



//----- Counting Iterator -----
class CountingIterator implements RandomAccessIterator<int>
{
  CountingIterator( int this._begin, int this._end, [ int this._step = 1, int this._pos = 0 ] );
  
  clone()
    => new CountingIterator( _begin, _end, _step, _pos );
  
  bool hasNext() => reference() < _end;
  int next() => this[_pos++];
  
  bool hasPrev() => this[_pos] > _end;
  int prev() => this[--_pos];
  
  int reference() => this[_pos];
  
  operator +( int i ) => new CountingIterator( _begin, _end, _step, _pos/* + i*/ );
  operator -( int i ) => this + -i;
  
  operator []( int elem ) => _begin + elem * _step;
  
  bool operator==( CountingIterator rhs ) => reference() == rhs.reference();
  int distance( CountingIterator it ) => ( reference() - it.reference() / _step ).abs();
  
  final int _begin, _end, _step;
  int _pos;
}
irange( int start, int last, [ int step = 1 ] )
  => new Range( new CountingIterator( start, last, step ), new CountingIterator( last, start, step ) );



//----- Range Modoki!! ----- 
class RangeIterator<T> implements BidirectionalIterator<T>
{
  RangeIterator( BidirectionalIterator<T> this._it, BidirectionalIterator<T> this._end );
  clone()
    => new RangeIterator( _it.clone(), _end.clone() );
    
  T reference() => _it.reference();

  bool hasNext() => _it.hasNext() && _it != _end;
  T next() => _it.next();
  
  bool hasPrev() => _it.hasPrev();
  T prev() => _it.prev();
  
  operator +( int i ) => new RangeIterator( ( i < -1 || i > 1 ) ? null : _it + i, _end );
  operator -( int i ) => this + -i;
  
  operator ==( RangeIterator<T> rhs ) => _it == rhs._it;
  int distance( RangeIterator<T> it ) => _it.distance( it );
  
  final BidirectionalIterator<T> _it, _end;
}

class Range<T> implements SimpleIterator<T>, Adaptable<T>
{
  Range( this._begin, this._end );

  RangeIterator<T> iterator() => new RangeIterator( begin(), end() );

  operator |( RangeAdaptor<T> adaptor ) => adaptor.apply( begin(), end() );
  
  begin() => _begin.clone();
  end() => _end.clone();
  
  int get length() => _begin.distance( _end );
  
  final SimpleIterator<T> _begin, _end;
}



//----- utility function -----

distance( SimpleIterator it1, SimpleIterator it2 ) => it1.distance( it2 );

range_equals( SampleIterable rng1, SampleIterable rng2 ) { 
  if ( rng1.length != rng2.length )
    return false;

  final rng1it = rng1.begin();
  for( final v in rng2 )
    if ( v != rng1it.next() )
      return false;
    
  return true;
}