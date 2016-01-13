/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* $Id: HyphenationTreeAnalysis.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package org.apache.fop.hyphenation;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;

/**
 * This class provides some useful methods to print the structure of a HyphenationTree object
 */
public class HyphenationTreeAnalysis extends TernaryTreeAnalysis {

    /**
     * The HyphenationTree object to analyse
     */
    protected HyphenationTree ht;

    /**
     * @param ht the HyphenationTree object
     */
    public HyphenationTreeAnalysis(HyphenationTree ht) {
        super(ht);
        this.ht = ht;
    }

    /**
     * Class representing a node of the HyphenationTree object
     */
    protected class Node extends TernaryTreeAnalysis.Node {
        private String value = null;

        /**
         * @param index the index of the node
         */
        protected Node(int index) {
            super(index);
            if (isLeafNode) {
                value = readValue().toString();
            }
        }

        private StringBuffer readValue() {
            StringBuffer s = new StringBuffer();
            int i = (int) ht.eq[index];
            byte v = ht.vspace.get(i);
            for (; v != 0; v = ht.vspace.get(++i)) {
                int c = (int) ((v >>> 4) - 1);
                s.append(c);
                c = (int) (v & 0x0f);
                if (c == 0) {
                    break;
                }
                c = (c - 1);
                s.append(c);
            }
            return s;
        }

        /* (non-Javadoc)
         * @see org.apache.fop.hyphenation.TernaryTreeAnalysis.Node#toNodeString()
         */
        public String toNodeString() {
            if (isLeafNode) {
                StringBuffer s = new StringBuffer();
                s.append("-" + index);
                if (isPacked) {
                    s.append(",=>'" + key + "'");
                }
                s.append("," + value);
                s.append(",leaf");
                return s.toString();
            } else {
                return super.toNodeString();
            }
        }

        /* (non-Javadoc)
         * @see org.apache.fop.hyphenation.TernaryTreeAnalysis.Node#toCompactString()
         */
        public String toCompactString() {
            if (isLeafNode) {
                StringBuffer s = new StringBuffer();
                s.append("-" + index);
                if (isPacked) {
                    s.append(",=>'" + key + "'");
                }
                s.append("," + value);
                s.append(",leaf\n");
                return s.toString();
            } else {
                return super.toCompactString();
            }
        }

        /* (non-Javadoc)
         * @see java.lang.Object#toString()
         */
        public String toString() {
            StringBuffer s = new StringBuffer();
            s.append(super.toString());
            if (isLeafNode) {
                s.append("value: " + value + "\n");
            }
            return s.toString();
        }

    }

    private void addNode(int nodeIndex, List strings, NodeString ns) {
        int pos = ns.indent + ns.string.length() + 1;
        Node n = new Node(nodeIndex);
        ns.string.append(n.toNodeString());
        if (n.high != 0) {
            ns.high.add(new Integer(pos));
            NodeString highNs = new NodeString(pos);
            highNs.low.add(new Integer(pos));
            int index = strings.indexOf(ns);
            strings.add(index, highNs);
            addNode(n.high, strings, highNs);
        }
        if (n.low != 0) {
            ns.low.add(new Integer(pos));
            NodeString lowNs = new NodeString(pos);
            lowNs.high.add(new Integer(pos));
            int index = strings.indexOf(ns);
            strings.add(index + 1, lowNs);
            addNode(n.low, strings, lowNs);
        }
        if (!n.isLeafNode) {
            addNode(n.equal, strings, ns);
        }

    }

    /**
     * Construct the tree representation of a list of node strings
     * @param strings the list of node strings
     * @return the string representing the tree
     */
    public String toTree(List strings) {
        StringBuffer indentString = new StringBuffer();
        for (int j = indentString.length(); j < ((NodeString) strings.get(0)).indent; ++j) {
            indentString.append(' ');
        }
        StringBuffer tree = new StringBuffer();
        for (int i = 0; i < strings.size(); ++i) {
            NodeString ns = (NodeString) strings.get(i);
            if (indentString.length() > ns.indent) {
                indentString.setLength(ns.indent);
            } else {
                // should not happen
                for (int j = indentString.length(); j < ns.indent; ++j) {
                    indentString.append(' ');
                }
            }
            tree.append(indentString);
            tree.append(ns.string + "\n");

            if (i + 1 == strings.size()) {
                continue;
            }
            for (int j = 0; j < ns.low.size(); ++j) {
                int pos = ((Integer) ns.low.get(j)).intValue();
                if (pos < indentString.length()) {
                    indentString.setCharAt(pos, '|');
                } else {
                    for (int k = indentString.length(); k < pos; ++k) {
                        indentString.append(' ');
                    }
                    indentString.append('|');
                }
            }
            tree.append(indentString + "\n");
        }

        return tree.toString();
    }

    /**
     * Construct the tree representation of the HyphenationTree object
     * @return the string representing the tree
     */
    public String toTree() {
        List strings = new ArrayList();
        NodeString ns = new NodeString(0);
        strings.add(ns);
        addNode(1, strings, ns);
        return toTree(strings);
    }

    /**
     * Construct the compact node representation of the HyphenationTree object
     * @return the string representing the tree
     */
    public String toCompactNodes() {
        StringBuffer s = new StringBuffer();
        for (int i = 1; i < ht.sc.length; ++i) {
            if (i != 1) {
                s.append("\n");
            }
            s.append((new Node(i)).toCompactString());
        }
        return s.toString();
    }

    /**
     * Construct the node representation of the HyphenationTree object
     * @return the string representing the tree
     */
    public String toNodes() {
        StringBuffer s = new StringBuffer();
        for (int i = 1; i < ht.sc.length; ++i) {
            if (i != 1) {
                s.append("\n");
            }
            s.append((new Node(i)).toString());
        }
        return s.toString();
    }

    /**
     * Construct the printed representation of the HyphenationTree object
     * @return the string representing the tree
     */
    public String toString() {
        StringBuffer s = new StringBuffer();

        s.append("classes: \n");
        s.append((new TernaryTreeAnalysis(ht.classmap)).toString());

        s.append("\npatterns: \n");
        s.append(super.toString());
        s.append("vspace: ");
        for (int i = 0; i < ht.vspace.length(); ++i) {
            byte v = ht.vspace.get(i);
            if (v == 0) {
                s.append("--");
            } else {
                int c = (int) ((v >>> 4) - 1);
                s.append(c);
                c = (int) (v & 0x0f);
                if (c == 0) {
                    s.append("-");
                } else {
                    c = (c - 1);
                    s.append(c);
                }
            }
        }
        s.append("\n");

        return s.toString();
    }

    /**
     * Provide interactive access to a HyphenationTree object and its representation methods
     * @param args the arguments
     */
    public static void main(String[] args) {
        HyphenationTree ht = null;
        HyphenationTreeAnalysis hta = null;
        int minCharCount = 2;
        BufferedReader in = new BufferedReader(new java.io.InputStreamReader(System.in));
        while (true) {
            System.out.print("l:\tload patterns from XML\n"
                             + "L:\tload patterns from serialized object\n"
                             + "s:\tset minimun character count\n"
                             + "w:\twrite hyphenation tree to object file\n"
                             + "p:\tprint hyphenation tree to stdout\n"
                             + "n:\tprint hyphenation tree nodes to stdout\n"
                             + "c:\tprint compact hyphenation tree nodes to stdout\n"
                             + "t:\tprint tree representation of hyphenation tree to stdout\n"
                             + "h:\thyphenate\n"
                             + "f:\tfind pattern\n"
                             + "b:\tbenchmark\n"
                             + "q:\tquit\n\n"
                             + "Command:");
            try {
                String token = in.readLine().trim();
                if (token.equals("f")) {
                    System.out.print("Pattern: ");
                    token = in.readLine().trim();
                    System.out.println("Values: " + ht.findPattern(token));
                } else if (token.equals("s")) {
                    System.out.print("Minimum value: ");
                    token = in.readLine().trim();
                    minCharCount = Integer.parseInt(token);
                } else if (token.equals("l")) {
                    ht = new HyphenationTree();
                    hta = new HyphenationTreeAnalysis(ht);
                    System.out.print("XML file name: ");
                    token = in.readLine().trim();
                    try {
                        ht.loadPatterns(token);
                    } catch (HyphenationException e) {
                        e.printStackTrace();
                    }
                } else if (token.equals("L")) {
                    ObjectInputStream ois = null;
                    System.out.print("Object file name: ");
                    token = in.readLine().trim();
                    try {
                        String[] parts = token.split(":");
                        InputStream is = null;
                        if (parts.length == 1) {
                            is = new FileInputStream(token);
                        } else if (parts.length == 2) {
                            ZipFile jar = new ZipFile(parts[0]);
                            ZipEntry entry = new ZipEntry(jar.getEntry(parts[1]));
                            is = jar.getInputStream(entry);
                        }
                        ois = new ObjectInputStream(is);
                        ht = (HyphenationTree) ois.readObject();
                        hta = new HyphenationTreeAnalysis(ht);
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (ois != null) {
                            try {
                                ois.close();
                            } catch (IOException e) {
                                //ignore
                            }
                        }
                    }
                } else if (token.equals("w")) {
                    System.out.print("Object file name: ");
                    token = in.readLine().trim();
                    ObjectOutputStream oos = null;
                    try {
                        oos = new ObjectOutputStream(new FileOutputStream(token));
                        oos.writeObject(ht);
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (oos != null) {
                            try {
                                oos.flush();
                            } catch (IOException e) {
                                //ignore
                            }
                            try {
                                oos.close();
                            } catch (IOException e) {
                                //ignore
                            }
                        }
                    }
                } else if (token.equals("p")) {
                    System.out.print(hta);
                } else if (token.equals("n")) {
                    System.out.print(hta.toNodes());
                } else if (token.equals("c")) {
                    System.out.print(hta.toCompactNodes());
                } else if (token.equals("t")) {
                    System.out.print(hta.toTree());
                } else if (token.equals("h")) {
                    System.out.print("Word: ");
                    token = in.readLine().trim();
                    System.out.print("Hyphenation points: ");
                    System.out.println(ht.hyphenate(token, minCharCount,
                                                    minCharCount));
                } else if (token.equals("b")) {
                    if (ht == null) {
                        System.out.println("No patterns have been loaded.");
                        break;
                    }
                    System.out.print("Word list filename: ");
                    token = in.readLine().trim();
                    long starttime = 0;
                    int counter = 0;
                    try {
                        BufferedReader reader = new BufferedReader(new FileReader(token));
                        String line;

                        starttime = System.currentTimeMillis();
                        while ((line = reader.readLine()) != null) {
                            // System.out.print("\nline: ");
                            Hyphenation hyp = ht.hyphenate(line, minCharCount,
                                                           minCharCount);
                            if (hyp != null) {
                                String hword = hyp.toString();
                                // System.out.println(line);
                                // System.out.println(hword);
                            } else {
                                // System.out.println("No hyphenation");
                            }
                            counter++;
                        }
                    } catch (Exception ioe) {
                        System.out.println("Exception " + ioe);
                        ioe.printStackTrace();
                    }
                    long endtime = System.currentTimeMillis();
                    long result = endtime - starttime;
                    System.out.println(counter + " words in " + result
                                       + " Milliseconds hyphenated");

                } else if (token.equals("q")) {
                    break;
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }

}
