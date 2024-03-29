# -*- cperl -*-
use Test;
BEGIN { plan tests=>104; }
use XML::LibXML;
use XML::LibXML::Common qw(:libxml);

my $parser = XML::LibXML->new();

my $xml1 = <<EOX;
<a xmlns:b="http://whatever"
><x b:href="out.xml"
/><b:c/></a>
EOX

my $xml2 = <<EOX;
<a xmlns:b="http://whatever" xmlns:c="http://kungfoo"
><x b:href="out.xml"
/><b:c/><c:b/></a>
EOX

my $xml3 = <<EOX;
<a xmlns:b="http://whatever">
    <x b:href="out.xml"/>
    <x>
    <c:b xmlns:c="http://kungfoo">
        <c:d/>
    </c:b>
    </x>
    <x>
    <c:b xmlns:c="http://foobar">
        <c:d/>
    </c:b>
    </x>
</a>
EOX

print "# 1.   single namespace \n";

{
    my $doc1 = $parser->parse_string( $xml1 );
    my $elem = $doc1->documentElement;
    ok($elem->lookupNamespaceURI( "b" ), "http://whatever" );
    my @cn = $elem->childNodes;
    ok($cn[0]->lookupNamespaceURI( "b" ), "http://whatever" );
    ok($cn[1]->namespaceURI, "http://whatever" );
}

print "# 2.    multiple namespaces \n";

{
    my $doc2 = $parser->parse_string( $xml2 );

    my $elem = $doc2->documentElement;
    ok($elem->lookupNamespaceURI( "b" ), "http://whatever");
    ok($elem->lookupNamespaceURI( "c" ), "http://kungfoo");
    my @cn = $elem->childNodes;

    ok($cn[0]->lookupNamespaceURI( "b" ), "http://whatever" );
    ok($cn[0]->lookupNamespaceURI( "c" ), "http://kungfoo");

    ok($cn[1]->namespaceURI, "http://whatever" );
    ok($cn[2]->namespaceURI, "http://kungfoo" );
}

print "# 3.   nested names \n";

{
    my $doc3 = $parser->parse_string( $xml3 );    
    my $elem = $doc3->documentElement;
    my @cn = $elem->childNodes;
    my @xs = grep { $_->nodeType == XML_ELEMENT_NODE } @cn;

    my @x1 = $xs[1]->childNodes; my @x2 = $xs[2]->childNodes;

    ok( $x1[1]->namespaceURI , "http://kungfoo" );    
    ok( $x2[1]->namespaceURI , "http://foobar" );    

    # namespace scopeing
    ok( not defined $elem->lookupNamespacePrefix( "http://kungfoo" ) );
    ok( not defined $elem->lookupNamespacePrefix( "http://foobar" ) );
}

print "# 4. post creation namespace setting\n";
{
    my $e1 = XML::LibXML::Element->new("foo");
    my $e2 = XML::LibXML::Element->new("bar:foo");
    my $e3 = XML::LibXML::Element->new("foo");
    $e3->setAttribute( "kung", "foo" );
    my $a = $e3->getAttributeNode("kung");

    $e1->appendChild($e2);
    $e2->appendChild($e3);
    ok( $e2->setNamespace("http://kungfoo", "bar") );
    ok( $a->setNamespace("http://kungfoo", "bar") );
    ok( $a->nodeName, "bar:kung" );
}

print "# 5. importing namespaces\n";

{

    my $doca = XML::LibXML->createDocument;
    my $docb = XML::LibXML->new()->parse_string( <<EOX );
<x:a xmlns:x="http://foo.bar"><x:b/></x:a>
EOX

    my $b = $docb->documentElement->firstChild;

    my $c = $doca->importNode( $b );

    my @attra = $c->attributes;
    ok( scalar(@attra), 1 );
    ok( $attra[0]->nodeType, 18 );
    my $d = $doca->adoptNode($b);

    ok( $d->isSameNode( $b ) );
    my @attrb = $d->attributes;
    ok( scalar(@attrb), 1 );
    ok( $attrb[0]->nodeType, 18 );
}

print "# 6. lossless setting of namespaces with setAttribute\n";
# reported by Kurt George Gjerde
{
    my $doc = XML::LibXML->createDocument; 
    my $root = $doc->createElementNS('http://example.com', 'document');
    $root->setAttribute('xmlns:xxx', 'http://example.com');
    $root->setAttribute('xmlns:yyy', 'http://yonder.com');
    $doc->setDocumentElement( $root );

    my $strnode = $root->toString();
    ok ( $strnode =~ /xmlns:xxx/ and $strnode =~ /xmlns=/ );
}

print "# 7. namespaced attributes\n";
{
  my $doc = XML::LibXML->new->parse_string(<<'EOF');
<test xmlns:xxx="http://example.com"/>
EOF
  my $root = $doc->getDocumentElement();
  # namespaced attributes
  $root->setAttribute('xxx:attr', 'value');
  ok ( $root->getAttributeNode('xxx:attr') );
  ok ( $root->getAttribute('xxx:attr'), 'value' );
  print $root->toString(1),"\n";
  ok ( $root->getAttributeNodeNS('http://example.com','attr') );
  ok ( $root->getAttributeNS('http://example.com','attr'), 'value' );
  ok ( $root->getAttributeNode('xxx:attr')->getNamespaceURI(), 'http://example.com');
}

print "# 8. changing namespace declarations\n";
{
  my $xmlns = 'http://www.w3.org/2000/xmlns/';

    my $doc = XML::LibXML->createDocument; 
    my $root = $doc->createElementNS('http://example.com', 'document');
    $root->setAttributeNS($xmlns, 'xmlns:xxx', 'http://example.com');
    $root->setAttribute('xmlns:yyy', 'http://yonder.com');
    $doc->setDocumentElement( $root );

    # can we get the namespaces ?
    ok ( $root->getAttribute('xmlns:xxx'), 'http://example.com');
    ok ( $root->getAttributeNS($xmlns,'xmlns'), 'http://example.com' );
    ok ( $root->getAttribute('xmlns:yyy'), 'http://yonder.com');
    ok ( $root->lookupNamespacePrefix('http://yonder.com'), 'yyy');
    ok ( $root->lookupNamespaceURI('yyy'), 'http://yonder.com');

    # can we change the namespaces ?
    ok ( $root->setAttribute('xmlns:yyy', 'http://newyonder.com') );
    ok ( $root->getAttribute('xmlns:yyy'), 'http://newyonder.com');
    ok ( $root->lookupNamespacePrefix('http://newyonder.com'), 'yyy');
    ok ( $root->lookupNamespaceURI('yyy'), 'http://newyonder.com');

    # can we change the default namespace ?
    $root->setAttribute('xmlns', 'http://other.com' );
    ok ( $root->getAttribute('xmlns'), 'http://other.com' );
    ok ( $root->lookupNamespacePrefix('http://other.com'), "" );
    ok ( $root->lookupNamespaceURI(''), 'http://other.com' );

    # non-existent namespaces
    ok ( $root->lookupNamespaceURI('foo'), undef );
    ok ( $root->lookupNamespacePrefix('foo'), undef );
    ok ( $root->getAttribute('xmlns:foo'), undef );

    # changing namespace declaration URI and prefix
    ok ( $root->setNamespaceDeclURI('yyy', 'http://changed.com') );
    ok ( $root->getAttribute('xmlns:yyy'), 'http://changed.com');
    ok ( $root->lookupNamespaceURI('yyy'), 'http://changed.com');
    eval { $root->setNamespaceDeclPrefix('yyy','xxx'); };
    ok ( $@ );  # prefix occupied
    eval { $root->setNamespaceDeclPrefix('yyy',''); };
    ok ( $@ );  # prefix occupied
    ok ( $root->setNamespaceDeclPrefix('yyy', 'zzz') );
    ok ( $root->lookupNamespaceURI('yyy'), undef );
    ok ( $root->lookupNamespaceURI('zzz'), 'http://changed.com' );
    ok ( $root->setNamespaceDeclURI('zzz',undef ) ); 
    ok ( $root->lookupNamespaceURI('zzz'), undef );
    $strnode = $root->toString();
    ok ( $strnode !~ /xmlns:zzz/ );

    # changing the default namespace declaration
    ok ( $root->setNamespaceDeclURI('','http://test') );	
    ok ( $root->lookupNamespaceURI(''), 'http://test' );
    ok ( $root->getNamespaceURI(), 'http://test' );

    # changing prefix of the default ns declaration
    ok ( $root->setNamespaceDeclPrefix('','foo') );	
    ok ( $root->lookupNamespaceURI(''), undef );
    ok ( $root->lookupNamespaceURI('foo'), 'http://test' );
    ok ( $root->getNamespaceURI(),  'http://test' );
    ok ( $root->prefix(),  'foo' );

    # turning a ns declaration to a default ns declaration
    ok ( $root->setNamespaceDeclPrefix('foo','') );	
    ok ( $root->lookupNamespaceURI('foo'), undef );
    ok ( $root->lookupNamespaceURI(''), 'http://test' );
    ok ( $root->lookupNamespaceURI(undef), 'http://test' );
    ok ( $root->getNamespaceURI(),  'http://test' );
    ok ( $root->prefix(),  undef );

    # removing the default ns declaration
    ok ( $root->setNamespaceDeclURI('',undef) );
    ok ( $root->lookupNamespaceURI(''), undef );
    ok ( $root->getNamespaceURI(), undef );

    $strnode = $root->toString();
    ok ( $strnode !~ /xmlns=/ );

    # namespaced attributes
    $root->setAttribute('xxx:attr', 'value');
    ok ( $root->getAttributeNode('xxx:attr') );
    ok ( $root->getAttribute('xxx:attr'), 'value' );
    print $root->toString(1),"\n";
   ok ( $root->getAttributeNodeNS('http://example.com','attr') );
   ok ( $root->getAttributeNS('http://example.com','attr'), 'value' );
   ok ( $root->getAttributeNode('xxx:attr')->getNamespaceURI(), 'http://example.com');

    # removing other xmlns declarations
    $root->addNewChild('http://example.com', 'xxx:foo');
    ok( $root->setNamespaceDeclURI('xxx',undef) );	
    ok ( $root->lookupNamespaceURI('xxx'), undef );
    ok ( $root->getNamespaceURI(), undef );
    ok ( $root->firstChild->getNamespaceURI(), undef );
    ok ( $root->prefix(),  undef );
    ok ( $root->firstChild->prefix(),  undef );


    print $root->toString(1),"\n";
    # check namespaced attributes
    ok ( $root->getAttributeNode('xxx:attr'), undef );
   ok ( $root->getAttributeNodeNS('http://example.com', 'attr'), undef );
   ok ( $root->getAttributeNode('attr') );
    ok ( $root->getAttribute('attr'), 'value' );
   ok ( $root->getAttributeNodeNS(undef,'attr') );
   ok ( $root->getAttributeNS(undef,'attr'), 'value' );
    ok ( $root->getAttributeNode('attr')->getNamespaceURI(), undef);


    $strnode = $root->toString();
    ok ( $strnode !~ /xmlns=/ );
    ok ( $strnode !~ /xmlns:xxx=/ );
    ok ( $strnode =~ /<foo/ );
    
    ok ( $root->setNamespaceDeclPrefix('xxx',undef) );

    ok ( $doc->findnodes('/document/foo')->size(), 1 );
    ok ( $doc->findnodes('/document[foo]')->size(), 1 );
    ok ( $doc->findnodes('/document[*]')->size(), 1 );
   ok ( $doc->findnodes('/document[@attr and foo]')->size(), 1 );
   ok ( $doc->findvalue('/document/@attr'), 'value' );

    $xp = XML::LibXML::XPathContext->new($doc);
    ok ( $xp->findnodes('/document/foo')->size(), 1 );
    ok ( $xp->findnodes('/document[foo]')->size(), 1 );
    ok ( $xp->findnodes('/document[*]')->size(), 1 );

   ok ( $xp->findnodes('/document[@attr and foo]')->size(), 1 );
   ok ( $xp->findvalue('/document/@attr'), 'value' );

    ok ( $root->firstChild->prefix(),  undef );
}
