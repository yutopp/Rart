// Copyright yutopp 2012.
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

#import( "rart.dart" );

//-------------------------------------
//----- Dummy List Implementation -----
class DummyList<T> implements ReverseIterable<T>, Adaptable<T>/*, Collection<T>, default ListFactory<E>*/
{
  DummyList( List<T> this._list );
  
  ForwardIterator<T> iterator() => begin();
  ForwardIterator<T> reverseIterator() => rbegin();
  
  operator |( RangeAdaptor<T> abaptor ) => abaptor.apply( begin(), end() );
  
  ListIterator<T> begin() => new ListIterator( _list );
  ListIterator<T> end() => new ListIterator.withPos( _list, _list.length );
  ListReverseIterator<T> rbegin() => new ListReverseIterator( _list );
  ListReverseIterator<T> rend() => new ListReverseIterator.withPos( _list, 0 );
  
  int get length() => _list.length;
  
  final List<T> _list;
}

//----- Iterator Trial Implementation For List -----
// Normal
class ListIterator<T> implements RandomAccessIterator<T> {
  ListIterator( List<T> list )
  : this.withPos( list, 0 );
  
  ListIterator.withPos( List<T> this._list, int this._pos );
  
  clone()
    => new ListIterator.withPos( _list, _pos );

  bool hasNext() => _pos < _list.length;

  T next() {
    if ( !hasNext() )
      throw const NoMoreElementsException();
    return _list[_pos++];
  }
  
  bool hasPrev() {
    return _pos >= 0;
  }

  T prev() {
    if ( !hasPrev() )
      throw const NoMoreElementsException();
    return _list[_pos--];
  }
  
  T reference() => _list[_pos];
  T operator[]( int elem ) => _list[elem];
  
  operator +( int i ) => new ListIterator.withPos( _list, _pos + i );
  operator -( int i ) => this + -i;
  
  /*operator equals*/
  bool operator ==( ListIterator<T> rhs ) => _list === rhs._list && _pos == rhs._pos;
  int distance( ListIterator<T> it ) => ( _pos - it._pos ).abs();
  
  final List<T> _list;
  int _pos;
}

// Reverse
class ListReverseIterator<T> implements RandomAccessIterator<T> {
  ListReverseIterator( List<T> list )
  : this.withPos( list, list.length );
  
  ListReverseIterator.withPos( List<T> list, int pos )
  : _it = new ListIterator.withPos( list, pos - 1 );
  
  clone()
    => new ListReverseIterator.withPos( _it._list, _it._pos );

  bool hasNext() => _it.hasPrev();
  T next() => _it.prev();
 
  bool hasPrev() => _it.hasNext();
  T prev() => _it.next();
  
  T reference() => _it.reference();
  T operator[]( int elem ) => _it[elem];
  
  operator +( int i ) => new ListReverseIterator( _it - i );
  operator -( int i ) => this + -i;
  
  bool operator ==( ListReverseIterator<T> rhs ) => _it == rhs._it;
  int distance( ListReverseIterator<T> it ) => _it.distance( it._it );
  
  final ListIterator<T> _it;
}


//
bool test_case( rng1, rng2 ) {
  print( "=> " + rng1.length + " : " + rng2.length );
  final bool b = range_equals( rng1, rng2 );
  print( "[ " + b + " ]" );
  
  for( final v in rng1 )
    print( v );  
  
  print( "-------------------" );
  
  return b;
}


//----- Main -----
void main()
{
  final it1 = ( irange( 5, 10, 2 ) | filtered( (i) => i == 5 || i == 7 ) ).begin();
  final it2 = ( irange( 5, 10, 2 ) | filtered( (i) => i == 5 || i == 7 ) ).begin();
  print( distance( it1, it2 ) );
  it2.next();
  print( distance( it1, it2 ) );
  it2.next();
  print( distance( it1, it2 ) );
  
  print( "-------------------" );
  
  test_case( new DummyList( [1,2,3] ), new DummyList( [1,2,3] ) ); 
  
  test_case( irange( 0, 5 ), new DummyList( [0,1,2,3,4] ) ); 
  
  test_case( join( new DummyList( [1,2,3] ), new DummyList( [4,5,6,7,8,9] ) ), new DummyList( [1,2,3,4,5,6,7,8,9] ) ); 
  
  test_case( join( new DummyList( [1,2,3] ), new DummyList( [4,5,6,7,8,9] ) ) | reversed(), new DummyList( [9,8,7,6,5,4,3,2,1] ) );

  test_case( join( new DummyList( [1,2,3] ), new DummyList( [4,5,6,7,8,9] ) ) | sliced( 2, 5 ), new DummyList( [3,4,5] ) );

  test_case( join( new DummyList( [1,2,3] ), new DummyList( [4,5,6,7,8,9] ) ) | reversed() | sliced( 2, 5 ) | reversed() | sliced( 0, 2 ) | reversed(), new DummyList( [6,5] ) );   
  
  print("fail test");
  test_case( join( new DummyList( [1,2,3] ), new DummyList( [4,5,6,7,8,9] ) ), new DummyList( [6,5] ) );
  
  test_case( new DummyList( [1,2,3,4,5,6,7,8,9] ) | sliced( 2, 5 ) | reversed() | sliced( 0, 2 ), new DummyList( [5,4] ) ); 

  test_case( new DummyList( [1,2,3,4,5] ) | filtered( (i) => i == 1 ), new DummyList( [1] ) ); 
  
  test_case( new DummyList( [1,2,3,4,5,6,7,8,9] ) | filtered( (i) => i < 5 ) | sliced( 0, 2 ) | transformed( ( i ) => i*2 ) | reversed(), new DummyList( [4,2] ) );
 
  test_case( irange( 5, 10 ) | reversed() | filtered( (i) => i < 8 ) | reversed() | sliced( 0, 2 ), new DummyList( [5,6] ) ); 

  test_case( irange( 5, 10, 2 ) | filtered( (i) => i == 5 || i == 7 ), new DummyList( [5,7] ) );
  
  test_case( irange( 5, 10 ) | replaced( 8, 500 ), new DummyList( [5,6,7,500,9] ) );
  
  test_case( irange( 5, 10 ) | replaced_if( (i) => i<8, 500 ), new DummyList( [500,500,500,8,9] ) ); 
}