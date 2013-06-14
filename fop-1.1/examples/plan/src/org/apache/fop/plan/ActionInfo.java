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

/* $Id: ActionInfo.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package org.apache.fop.plan;

import java.util.Date;

public class ActionInfo {

    public static final int TASK = 1;
    public static final int MILESTONE = 2;
    public static final int GROUPING = 3;

    private Date startDate;
    private Date endDate;
    private String owner;
    private String label;
    private int type = TASK;
    private String dependant = "";

    public void setType(int t) {
        type = t;
    }

    public int getType() {
        return type;
    }

    public void setLabel(String str) {
        label = str;
    }

    public void setOwner(String str) {
        owner = str;
    }

    public void setStartDate(Date sd) {
        startDate = sd;
        if (endDate == null) {
            endDate = startDate;
        }
    }

    public void setEndDate(Date ed) {
        endDate = ed;
    }

    public String getLabel() {
        return label;
    }

    public String getOwner() {
        return owner;
    }

    public Date getStartDate() {
        return startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

}
