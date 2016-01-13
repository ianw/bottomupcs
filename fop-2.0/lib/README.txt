
Information on Apache FOP dependencies
=========================================

$Id$

The Apache Licenses can also be found here:
http://www.apache.org/licenses/


Normal Dependencies
----------------------

- Apache Jakarta Commons IO

    commons-io-*.jar
    http://jakarta.apache.org/commons/io/
    (I/O routines)
    
    Apache License v2.0
    
- Apache Jakarta Commons Logging

    commons-logging-*.jar
    http://jakarta.apache.org/commons/logging/
    (Logging adapter for various logging backends like JDK 1.4 logging or Log4J)
    
    Apache License v2.0

- Apache Avalon Framework

    avalon-framework-*.jar
    http://excalibur.apache.org/framework/
    (Avalon Framework, maintained by the Apache Excalibur project)
    
    Apache License v2.0

- Apache XML Graphics Commons

    xmlgraphics-commons-*.jar
    http://xmlgraphics.apache.org/
    (Common Library for Apache Batik and Apache FOP)
    
    Apache License v2.0

- Apache Batik

    batik-*.jar
    http://xmlgraphics.apache.org/batik/
    (SVG Implementation)
    
    Apache License v2.0

- Apache XML Commons Externals (JAXP API)

    xml-apis.jar
    http://xml.apache.org/commons/components/external/
    (the JAXP API, plus SAX and various W3C DOM Java bindings,
    maintained in XML Commons Externals)
    
    Apache License v2.0 (applies to the distribution)
    SAX is in the public domain
        http://www.saxproject.org/copying.html
    W3C Software Notice and License (applies to the various DOM Java bindings)
    W3C Document License (applies to the DOM documentation)
        http://www.w3.org/Consortium/Legal/copyright-software
        http://www.w3.org/Consortium/Legal/copyright-documents
        http://www.w3.org/Consortium/Legal/

    xml-apis-ext-*.jar
    http://xml.apache.org/commons/components/external/
    (additional DOM APIs from W3C, like SVG, SMIL and Simple API for CSS)
    
    Apache License v2.0 (applies to the distribution)
    W3C Software Notice and License (applies to the various DOM Java bindings)
    W3C Document License (applies to the DOM documentation)
        http://www.w3.org/Consortium/Legal/copyright-software
        http://www.w3.org/Consortium/Legal/copyright-documents
        http://www.w3.org/Consortium/Legal/

- Apache Xalan-J

    xalan-*.jar and serializer-*.jar
    http://xalan.apache.org
    (JAXP-compliant XSLT and XPath implementation)
    
    Apache License v2.0 (applies to Xalan-J)
    Apache License v1.1 (applies to Apache BCEL and Apache REGEXP bundled in the JAR)
    Historical Permission Notice and Disclaimer (applies to CUP Parser Generator)
        http://www.opensource.org/licenses/historical.php
        (see xalan.runtime.LICENSE.txt)


Special Dependencies
-----------------------

- Apache Xerces-J

    xercesImpl-*.jar
    http://xerces.apache.org
    (JAXP-compliant XML parser and DOM Level 3 implementation)
    
    Apache License v2.0
    
    Xerces-J is not directly referenced by FOP or any of its dependencies.
    

A note on JAXP
-----------------------

Since Java 1.4, JAXP (Java API for XML Processing) is part of the 
JRE/JDK. Every JVM includes the APIs and an implementation. However, 
older JREs often contain implementations with bugs that are triggered 
by code in Apache FOP and therefore need to be overridden. Now, since 
JAXP is part of the class library, special precautions are necessary 
to replace the original implementations. This is not done by simply 
adding new JARs to the classpath as these classes would never be 
loaded (due to Java's class loader hierarchy). 

Replacing the default implementations involves understanding the 
"Endorsed Standards Override Mechanism".
More information can be found here:
http://java.sun.com/j2se/1.4.2/docs/guide/standards/index.html

See also:
http://xml.apache.org/xalan-j/faq.html#faq-N100EF

Essentially, you have two different possibilities:
- add the replacement JARs in the jre/lib/endorsed directory of your JRE.
- Use the -Xbootclasspath/p: option when starting the JVM (may not be
  available for every JVM).


Optional Dependencies
------------------------

The following libraries are not bundled with FOP and must be installed manually.
Please make sure you've read the license of each package.

- JAI Image I/O Tools

    https://jai-imageio.dev.java.net/
    BSD license
    
    Note: This is not the same as JAI! Only the ImageIO-compatible codecs
    are packaged as "Image I/O Tools". The name may be misleading.

- JAI (Java Advanced Imaging API) 

    http://java.sun.com/products/java-media/jai 	 
    Java Research License and Java Distribution License (Check which one applies to you!)
    
    Currently used for:
    - Grayscale error diffusion dithering in the PCL Renderer

- JEuclid (MathML implementation, for the MathML extension)

    http://jeuclid.sourceforge.net/
    http://sourceforge.net/projects/jeuclid
    Apache License v1.1



Additional development-time dependencies
-------------------------------------------

- Servlet API

    servlet-*.jar
    http://jakarta.apache.org/tomcat/
    (Servlet API, javax.servlet)
    
    Apache License v1.1

- Apache Ant

    (not bundled, requires pre-installation)
    http://ant.apache.org
    (XML-based build system
    
    Apache License V2.0

- JUnit

    (not bundled, provided by Apache Ant or your IDE)
    http://www.junit.org
    Common Public License V1.0

- XMLUnit

    lib/build/xmlunit-*.jar
    (based on JUnit, used for testing)
    http://xmlunit.sourceforge.net/
    BSD style license

- QDox

    lib/build/qdox-*.jar
    (used by the processing feedback mechanism, not needed at runtime)
    http://qdox.codehaus.org/
    Apache License V2.0



Additional build-time dependencies
-------------------------------------------

These libraries are needed during the build only and
not at runtime.

- PMD

    lib/build/pmd14-*.jar
    (used for a code quality report)
    http://pmd.sourceforge.net/
    BSD style license

- Jaxen

    lib/build/jaxen-*.jar
    (required by PMD)
    http://jaxen.codehaus.org/
    BSD style license

- Retroweaver

    (currently used only to verify Java 1.4 compatibility)
    http://retroweaver.sourceforge.net
    BSD style license
    
- ASM

    lib/build/asm-*.jar
    (required by Retroweaver)
    http://asm.objectweb.org
    BSD style license
    
- backport-util-concurrent

    lib/build/backport-util-concurrent-*.jar
    (required by Retroweaver)
    http://backport-jsr166.sourceforge.net/
    in public domain