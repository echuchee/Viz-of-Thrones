import controlP5.*;
import java.util.*;

ControlP5 cp5;

DropdownList character1, character2, affiliation;
Button fwd, bkwd, bkwd2, pause;
RadioButton selection;
CheckBox pathToggle;

Slider animSpeed;
Textarea bio;

String characterName;
String characterBio;
Table bigCharacter;
Table paths;
Table smallerPaths;
Table episodes;

int selected = -1;
int selectedEp = 1;
int episodeMin;
int episodeMax;
int tempEpisodeMin, tempEpisodeMax;
float t = 0;
float state;

boolean paused = true;
boolean oneStep = false;
boolean fullPathsBool = false;
boolean dd1Clicked = false, dd2Clicked = false;
boolean t1, t2;

PImage map;
PImage characterImg;
PImage skull;
PImage pauseImg, playImg, rewindOneImg, rewindAllImg, skipOneImg;
PImage pauseImg2, playImg2, rewindOneImg2, rewindAllImg2, skipOneImg2;
PImage pauseImg3, playImg3, rewindOneImg3, rewindAllImg3, skipOneImg3;

Range range;

color c1, c2, c1s, c2s;
int xOffset, yOffset;

int[] barchart;
int[] barvalues;

int framecnt = 0;

HashMap<Line, Integer> aggregation;
HashMap<String, String> nameToAffiliation;

ArrayList<String> affiliationArray;
ArrayList<PVector> pathDictionary = new ArrayList<PVector>();
ArrayList<Integer> dictionaryCount = new ArrayList<Integer>();
ArrayList<ArrayList<String>> charPathList = new ArrayList<ArrayList<String>>();


void setup() {
  size(1630, 1000);
  c1 = color(204, 102, 0);
  c1s = color(255, 180, 159);
  c2 = color(76, 0, 153); //purple
  c2s = color(210, 180, 200);

  map = loadImage("pics/got.png");
  pauseImg = loadImage("pics/pause.png");
  playImg = loadImage("pics/play.png");
  rewindOneImg = loadImage("pics/rewind.png");
  rewindAllImg = loadImage("pics/skip_backward1.png");
  skipOneImg = loadImage("pics/fast_forward.png");
  pauseImg2 = loadImage("pics/pause2.png");
  playImg2 = loadImage("pics/play2.png");
  rewindOneImg2 = loadImage("pics/rewind2.png");
  rewindAllImg2 = loadImage("pics/skip_backward12.png");
  skipOneImg2 = loadImage("pics/fast_forward2.png");
  pauseImg3 = loadImage("pics/pause3.png");
  playImg3 = loadImage("pics/play3.png");
  rewindOneImg3 = loadImage("pics/rewind3.png");
  rewindAllImg3 = loadImage("pics/skip_backward13.png");
  skipOneImg3 = loadImage("pics/fast_forward3.png");
  pauseImg.resize(24, 24);
  playImg.resize(24, 24);
  rewindOneImg.resize(24, 24);
  rewindAllImg.resize(24, 24);
  skipOneImg.resize(24, 24);
  pauseImg2.resize(24, 24);
  playImg2.resize(24, 24);
  rewindOneImg2.resize(24, 24);
  rewindAllImg2.resize(24, 24);
  skipOneImg2.resize(24, 24);
  pauseImg3.resize(24, 24);
  playImg3.resize(24, 24);
  rewindOneImg3.resize(24, 24);
  rewindAllImg3.resize(24, 24);
  skipOneImg3.resize(24, 24);
  map.resize(1200, 800);
  xOffset = 430;
  yOffset = 0;

  skull = loadImage("pics/skull.png");

  cp5 = new ControlP5(this);

  bio = cp5.addTextarea("txt")
    //.setPosition(140,100)
    .setSize(250, 400)
      .setFont(createFont("arial", 12))
        .setLineHeight(14)
          .setColor(color(128))
            .setColorBackground(color(255, 100))
              .setColorForeground(color(255, 100));
  ;



  character2 = cp5.addDropdownList("Character2").setPosition(5, 80).setHeight(220).setItemHeight(20);
  character1 = cp5.addDropdownList("Character1").setPosition(5, 60).setHeight(240).setItemHeight(20);

  affiliation = cp5.addDropdownList("Affiliation").setPosition(5, 360).setHeight(300).setItemHeight(20);
  bkwd = cp5.addButton("<<").setSize(20, 20).setPosition(5, 850).setImage(rewindAllImg3);
  bkwd2 = cp5.addButton("<-").setSize(20, 20).setPosition(30, 850).setImage(rewindOneImg3);
  fwd = cp5.addButton("->").setSize(20, 20).setPosition(80, 850).setImage(skipOneImg3);
  pause = cp5.addButton("||>").setSize(20, 20).setPosition(55, 850).setImage(playImg3);

  animSpeed = cp5.addSlider("slider").setPosition(5, 900).setNumberOfTickMarks(51);
  animSpeed.valueLabel().setVisible(false);
  animSpeed.captionLabel().setVisible(false);

  selection = cp5.addRadioButton("radioButton")
    .setPosition(10, 750)
      .setSize(20, 20)
        .setColorForeground(color(150))
          .setColorActive(color(20))
            .setItemsPerRow(1)
              .addItem("Animation", 1)
                .addItem("Character Paths", 2)
                  .addItem("Aggregation", 3)
                    .addItem("Show Deaths", 4)
                      .setColorLabels(0).activate(1);
  ;
  pathToggle = cp5.addCheckBox("radioButton2")
    .setPosition(10, 710)
      .setSize(20, 20)
        .setColorForeground(color(150))
          .setColorActive(color(20))
            .setItemsPerRow(1)
              .addItem("Complete Paths", 0)
                .setColorLabels(0).setValue(0).toggle(0);
  ;
  state = 0;

  barchart = new int[50];
  barvalues = new int[50];

  bigCharacter = loadTable("BigCharacter.tsv"); //HAS ALL OF THE DATA
  paths = loadTable("allpaths.tsv", "header");
  episodes = loadTable("episodes.tsv", "header, tsv");
  smallerPaths = loadTable("allpaths.tsv", "header");

  customize(character1);
  customize(character2);
  customize(affiliation);
  resetDictionary();

  //SLIDER for EPISODE RANGE
  range = cp5.addRange("rangeController")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(510, height-100)
        .setSize(1000, 40)
          .setHandleSize(20)
            .setRange(1, 50)
              .setRangeValues(1, 50)
                .setDecimalPrecision(0)
                  // after the initialization we turn broadcast back on again
                  .setBroadcast(true)
                    .setColorForeground(color(255, 40))
                      .setColorBackground(color(0))  
                        ;

  episodeMin = 1;
  episodeMax = 50;

  if (fullPathsBool == true) {
    paths = loadTable("fullPaths.tsv", "header");
  } else if (fullPathsBool == false) {
    paths = loadTable("allpaths.tsv", "header");
  }
  state = 2;
  animSpeed.setValue(50);
  animSpeed.update();
}

void draw() {
  println(framecnt);
  framecnt+=1;
  background(255);
  textSize(20);
  fill(0);
  drawMapSection();
  drawCharactersSection();
  drawAffiliationsSection();
  drawControlsSection();
  drawBioSection();
  drawEpisodeSection(0);
  drawColors();
  if (isAnimation()) {
    if (paused != true && selectedEp < 51) {
      t += .01 + animSpeed.getValue() * .0008;
      //println(.01 + animSpeed.getValue() * .0008);
      //t += .05;
    }
    if (t >= 1 && selectedEp != 50) { 
      selectedEp +=1; 
      t= 0;
    } else if (t >= 1 && selectedEp == 50) {
      //doesnt increase selected episode
      t =1;
    }
    if (oneStep == true && selectedEp >= episodeMax) {
      paused = true;
      oneStep = false;
      episodeMax = tempEpisodeMax;
      episodeMin = tempEpisodeMin;
    }
    if (selectedEp == 51) {
      paused = true;
    } else if (selectedEp > episodeMax) {
      selectedEp = episodeMin;
      paused = true;
    }

    drawAll();
    stroke(0);
    fill(0);
  }
  if (isCharacterPaths()) {
    drawPaths();
  }
  if (isAggregation()) {
    drawAggregation();
    strokeWeight(1);
  }
  if (isDeaths()) {
    drawDeaths();
  }
  if (state == 1) {
    drawMouseOver(mouseUpdate());  //Draws mouse over animation circles.
  }
  btnHighlights();
}

void btnHighlights() {
  if (mouseY>=851 && mouseY <=869 && mousePressed == true) {
    if (mouseX>=6 && mouseX <= 24 &&(state == 1 || state == 2)) {
      bkwd.setImage(rewindAllImg2);
    } else if (mouseX <= 49 && mouseX >= 31 &&(state == 1 || state ==2)) {
      bkwd2.setImage(rewindOneImg2);
    } else if (mouseX <= 74 && mouseX >= 56 && (state == 1)) {
      if (paused == false) {
        pause.setImage(pauseImg2);
      } else {
        pause.setImage(playImg2);
      }
    } else if (mouseX >=81 && mouseX <=99 && (state ==1 || state ==2)) {
      fwd.setImage(skipOneImg2);
    }
  } else if (state == 1) {
    bkwd.setImage(rewindAllImg);
    bkwd2.setImage(rewindOneImg);
    fwd.setImage(skipOneImg);
    if (paused == false) {
      pause.setImage(pauseImg);
    } else {
      pause.setImage(playImg);
    }
  } else if (state == 2) {
    bkwd.setImage(rewindAllImg);
    bkwd2.setImage(rewindOneImg);
    fwd.setImage(skipOneImg);
    pause.setImage(playImg3);
  } else if (state ==3) {
    bkwd.setImage(rewindAllImg3);
    bkwd2.setImage(rewindOneImg3);
    fwd.setImage(skipOneImg3);
    pause.setImage(playImg3);
  }
}


void resetDictionary() {
  int i = 0;
  dictionaryCount = new ArrayList<Integer>();
  while (i < 100) {
    dictionaryCount.add(0);
    i++;
  }
  charPathList = new ArrayList<ArrayList<String>>();
  pathDictionary = new ArrayList<PVector>();
}

void checkDropDowns() {
  t1 = !(character1.getCaptionLabel().getText().equals("Nothing Selected"));
  t2 = !(character2.getCaptionLabel().getText().equals("Nothing Selected"));
}

void mousePressed() {// Manually flip these booleans that involve whether or not each dropdown list is open. They are also set to false if a character is selected in the action listener.
  if (mouseX >=5 && mouseX <103 && mouseY >= 52 && mouseY < 60) {
    dd1Clicked = !dd1Clicked;
  } 
  if (mouseX >=5 && mouseX < 103 && mouseY >= 72 &&  mouseY < 80) {
    dd2Clicked = !dd2Clicked;
  }
  if (mouseX >= 530 && mouseX <= 850 && mouseY >= 805 && mouseY <= 825) {
    link(episodes.getString(selectedEp-1, 2), "_new");
  }
  if (characterImg != null) {
    float wscale = 220.0 / characterImg.width;
    int h = (int) (characterImg.height * wscale);
    if (mouseX >= 140 && mouseX <= 430 && mouseY >= h && mouseY <= h+50) {
      for (int i = 1; i < bigCharacter.getRowCount (); i++) {
        if (bigCharacter.getString(i, 0).equals(characterName)) {
          link(bigCharacter.getString(i, 4), "_new");
          break;
        }
      }
    }
  }
}

void mouseWheel(MouseEvent e) { // When the character dropdownlists are open, this allows the user to scroll up and down via mouse wheel . 
  float val = e.getCount();
  if (dd1Clicked == true) {
    float curr = character1.getScrollPosition();
    if (curr >0 && curr <= 1 && val == 1) {
      character1.scroll((1-character1.getScrollPosition()) + .01);
    }
    if (curr <1 && curr >= 0  && val == -1) {
      character1.scroll((1-character1.getScrollPosition()) - .01);
    }
  }
  if (dd2Clicked == true) {
    float curr = character2.getScrollPosition();
    if (curr >0 && curr <= 1 && val == 1) {
      character2.scroll((1-character2.getScrollPosition()) + .01);
    }
    if (curr <1 && curr >= 0  && val == -1) {
      character2.scroll((1-character2.getScrollPosition()) - .01);
    }
  }
}
String mouseUpdate() { // Returns the string of characters that the user is hovering over in the animation.
  String returnCharacterList = "";
  for (PVector p : pathDictionary) {
    int tempIndex2 = pathDictionary.indexOf(p);
    int k = dictionaryCount.get(tempIndex2);
    //ellipse(p.x,p.y,4+(k*2),4+(k*2));
    float disX = p.x -mouseX;
    float disY = p.y -mouseY;
    float diameter = 4+(k*2);
    if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
      ArrayList<String> tempC = charPathList.get(tempIndex2);
      int first = 0;
      for (String s : tempC) {
        if (first ==0) {
          returnCharacterList += s; 
          first +=1;
        } else {
          returnCharacterList =returnCharacterList + "," + s;
        }
      }
      return returnCharacterList;
    }
  }
  return ""; // Returns an empty string if the mouse isn't over anything.
}

void drawMouseOver(String s) { // Method is reponsible for drawing a box/text mouseover.The box is taller if there are more characters present.
  if (!s.equals("")) {
    stroke(0, 0, 0);
    fill(255, 255, 255);
    textSize(8);
    int h = 1; // # of rows in the box, max of 4
    int w = 0; // width of box, added later
    int listCount = 0;
    String[] list = split(s, ","); // Splits the input string by commas to divide the list into 4 separate lines.
    String line1 = "";
    String line2 = "";
    String line3 = "";
    String line4 = "";
    for (String l : list) {
      if (listCount == 0) {
        line1 = l;
      } else if (listCount < 4) {
        line1 = line1 + " , " + l;
      } else if (listCount == 4) {
        line2 = l; 
        h+=1;
      } else if (listCount > 4 && listCount < 8) {
        line2 = line2 + " , " + l;
      } else if (listCount == 8) {
        line3 = l; 
        h+=1;
      } else if (listCount > 8 && listCount < 12) {
        line3 = line3 + " , " + l;
      } else if (listCount == 12) {
        line4 = l; 
        h+=1;
      } else if (listCount > 12 && listCount < 16) {
        line4 = line4 + " , " + l;
      }
      listCount +=1;
    }
    int fixMaxWidth = 0;// Adjusts the width to be the size of the greatest line width.
    if (int(textWidth(line1))> fixMaxWidth) {
      fixMaxWidth = int(textWidth(line1));
    }
    if (int(textWidth(line2)) > fixMaxWidth) {
      fixMaxWidth = int(textWidth(line2));
    }
    if (int(textWidth(line3))> fixMaxWidth) {
      fixMaxWidth = int(textWidth(line3));
    }
    if (int(textWidth(line4)) > fixMaxWidth) {
      fixMaxWidth = int(textWidth(line4));
    }
    rect(mouseX, mouseY, fixMaxWidth+2, 12*h);
    fill(0, 0, 0);
    if (h >= 1) {
      text(line1, mouseX, mouseY+10);
    }
    if (h >= 2) {
      text(line2, mouseX, mouseY+20);
    }
    if (h >= 3) {
      text(line3, mouseX, mouseY+30);
    }
    if (h == 4) {
      text(line4, mouseX, mouseY+40);
    }
  }
}

void drawAll() {
  resetDictionary(); // Resets the dictionaries so that they don't start repeating themselves after every frame.
  checkDropDowns();  // Checks the status of the dropdowns to see if items are selected and adjust booleans based off of this. 
  for (TableRow row : paths.rows ()) {  // For each row in the paths file.
    if (row.getInt(0) == selectedEp) {  // If the row has the same episode as the selected one.
      // println(row.getString(1));
      float invt = 1-t;                 // Inverse t value used in the interpolation. T is between 0 and 1(updates in draw) Where 0 is at the start of the episode and 1 is at the end of the episode(final location).
      PVector p1 = new PVector(row.getInt(2) + xOffset, row.getInt(3) + yOffset); //P1 represents the start point. The offsets are the map offsets(0,430). I used these in case we do a zooming feature in the future.
      PVector p2 = new PVector(row.getInt(4) + xOffset, row.getInt(5) + yOffset); //P2 represents the end point for the episode.
      int tempIndex = pathDictionary.indexOf(new PVector(round((p1.x*invt)+(p2.x*t)), round((p1.y*invt)+(p2.y*t)))); // Checks to see if the current point is in the path dictionary for aggregation.
      TableRow tr = bigCharacter.findRow(row.getString(1), 0);
      if (tempIndex == -1) { // If the point is NOT in the path dictionary, the code below adds it. 
        if (affiliation.getCaptionLabel().getText() == "All Characters" || tr.getString(5).equals(affiliation.getCaptionLabel().getText())) {   //Checks to see the affiliation before adding the point.
          if (p1 == p2) {
            pathDictionary.add(new PVector(p1.x, p1.y));
          } else {
            pathDictionary.add(new PVector(round((p1.x*invt)+(p2.x*t)), round((p1.y*invt)+(p2.y*t)))); // Adds location of point to path dictionary.
          }
          dictionaryCount.add(tempIndex);
          ArrayList<String> tempCharList = new ArrayList<String>();
          tempCharList.add(row.getString(1));
          charPathList.add(tempCharList);
        }
      } else if (affiliation.getCaptionLabel().getText() == "All Characters" || tr.getString(5).equals(affiliation.getCaptionLabel().getText())) { // If the path dictionary has the point, increment the count to it in dictionaryCount.
        int tempIndex3 = dictionaryCount.get(tempIndex) +1;
        ArrayList<String> tempCharList2 = charPathList.get(tempIndex);
        tempCharList2.add(row.getString(1));
        charPathList.set(tempIndex, tempCharList2);
        dictionaryCount.set(tempIndex, tempIndex3);
      }
      for (PVector p : pathDictionary) { // For each path in the path dictionary, calculates the size of each circle and draws it. 
        //Accounts for smaller circles from selected characters being drawn into bigger ones.

        int tempIndex2 = pathDictionary.indexOf(p);
        int k = dictionaryCount.get(tempIndex2);
        strokeWeight(1);
        //noStroke();
        fill(102, 255, 102);                                          //Default animation color, NEED to change this to transparent?.
        int tempWidth = 6+(k*2);
        int fixedWidth = 6;
        int tempFix = int(tempWidth/4);
        //rect(p.x,p.y,tempWidth,tempWidth);
        ellipse(p.x, p.y, tempWidth, tempWidth);                     //Draws aggregated circles.
        ArrayList al = charPathList.get(tempIndex2);
        for (Object al2 : al) {
          if (t1 && al2.equals(character1.getCaptionLabel().getText())) {
            fill(c1);
            if (al.size() ==1) {
              ellipse(p.x, p.y, tempWidth, tempWidth);
            } else if (al.contains(character2.getCaptionLabel().getText())) {
              ellipse(p.x+tempFix, p.y, fixedWidth, fixedWidth);                                        //Offsets the colored selected character dot if the bigger circle contains both.
            } else {
              ellipse(p.x, p.y, fixedWidth, fixedWidth);                                            // Doesn't offset the dot. Places it in the center of the bigger circle.
            }
          }
          if (t2 && al2.equals(character2.getCaptionLabel().getText())) {
            fill(c2);
            if (al.size() ==1) {
              ellipse(p.x, p.y, tempWidth, tempWidth);
            } else if (al.contains(character1.getCaptionLabel().getText())) {
              ellipse(p.x-tempFix, p.y, fixedWidth, fixedWidth);                                        //Offsets the colored selected character dot if the bigger circle contains both.
            } else {
              ellipse(p.x, p.y, fixedWidth, fixedWidth);                                            // Doesn't offset the dot. Places it in the center of the bigger circle.
            }
          }
        }
      }
    }
  }
}

void drawPaths() {
  checkDropDowns();
  int currentEpx1 = 0;
  int currentEpy1 = 0;
  int currentEpx2 = 0;
  int currentEpy2 = 0;
  if (t1) {
    for (TableRow row : paths.rows ()) {
      if (row.getInt(0) >= episodeMin && row.getInt(0) <= episodeMax) {
        if (row.getString(1).equals(character1.getCaptionLabel().getText())) {
          line(xOffset + row.getInt(2), yOffset + row.getInt(3), xOffset + row.getInt(4), yOffset + row.getInt(5));
          strokeWeight(2);
          if (row.getInt(0) <= selectedEp) {
            stroke(c1);
            fill(c1);
          } else {
            stroke(c1s);
            fill(c1s);
          }
          line(xOffset + row.getInt(2), yOffset + row.getInt(3), xOffset + row.getInt(4), yOffset + row.getInt(5));
          strokeWeight(2);
          stroke(c1);
          if (selectedEp == row.getInt(0)) {
            currentEpx1 = row.getInt(4);
            currentEpy1 = row.getInt(5);
          }
        }
      }
    }
    if (currentEpx1 !=0) {
      noFill();
      fill(c1);
      noStroke();
      //strokeWeight(2);
      ellipse(xOffset + currentEpx1, yOffset+currentEpy1, 12, 12);
    }
  }
  if (t2) {
    for (TableRow row : paths.rows ()) {
      if (row.getInt(0) >= episodeMin && row.getInt(0) <= episodeMax) {
        if (row.getString(1).equals(character2.getCaptionLabel().getText())) {
          line(xOffset + row.getInt(2), yOffset + row.getInt(3), xOffset + row.getInt(4), yOffset + row.getInt(5));
          strokeWeight(2);
          if (row.getInt(0) <= selectedEp) {
            stroke(c2);
            fill(c2);
          } else {
            stroke(c2s);
            fill(c2s);
          }
          line(xOffset + row.getInt(2), yOffset + row.getInt(3), xOffset + row.getInt(4), yOffset + row.getInt(5));
          stroke(c2);
          strokeWeight(2);
          if (selectedEp == row.getInt(0)) {
            currentEpx2 = row.getInt(4);
            currentEpy2 = row.getInt(5);
          }
        }
      }
    }
    if (currentEpx2 !=0) {
      fill(c2);
      if (currentEpx2 == currentEpx1 && currentEpy1 == currentEpy2) {
        noStroke();
        //strokeWeight(2);
        arc(xOffset + currentEpx2, yOffset+currentEpy2, 12, 12, -HALF_PI, HALF_PI);
        //ellipse(xOffset + currentEpx2,yOffset+currentEpy2,5,5);
      } else {
        //strokeWeight(3);
        noStroke();
        ellipse(xOffset + currentEpx2, yOffset+currentEpy2, 12, 12);
      }
    }
  }
  strokeWeight(1);
  stroke(#000000);
  fill(#000000);
}

void drawDeaths() {
  HashMap<PVector, Integer> deathfreq = new HashMap<PVector, Integer>();

  int skullWidth = skull.width;
  int skullHeight = skull.height;
  Table temp = loadTable("allpaths.tsv", "header");
  temp.clearRows();
  for (TableRow rows : bigCharacter.rows ()) {
    if (rows.getInt(3) > episodeMin && rows.getInt(3) < episodeMax) {
      for (TableRow row : paths.matchRows (rows.getString (0), 1)) {
        temp.addRow(row);
      }
      int realx = temp.getInt(temp.getRowCount() - 1, 4) + xOffset - 5;
      int realy = temp.getInt(temp.getRowCount() - 1, 5) + yOffset - 5;
      PVector xy = new PVector(realx, realy);
      if (deathfreq.containsKey(xy)) {
        deathfreq.put(xy, deathfreq.get(xy) + 1);
      } else { 
        deathfreq.put(xy, 1);
      }
    }
  }
  for (PVector pvectors : deathfreq.keySet ()) {
    tint(255, 200);
    image(skull, pvectors.x, pvectors.y, skullWidth + (deathfreq.get(pvectors) * 2) - 6, skullHeight + (deathfreq.get(pvectors) * 2) - 6);
    tint(255, 255);
  }
}

void drawColors() {
  if (selected != 0) {
    fill(#939393);
    stroke(#000000);
    strokeWeight(3);
    int q = selected; //1 - > 6
    rect(2, 46+((selected-1)*20), 117, 16); // Selection box around dropdown
  }
  strokeWeight(1);
  fill(c1);
  rect(105, 50, 10, 8);
  fill(c2);
  rect(105, 70, 10, 8);
}

void drawCharactersSection() {
  text("Characters", 10, 28);
  line(0, 0, 120, 0);
  line(120, 0, 120, height);
  line(0, 40, 120, 40);
  line(0, 0, 0, height);
  line(0, height, 120, height);
}

void drawAffiliationsSection() {
  line(510, height-50, 510, height-30);
  line(710, height-50, 710, height-30);
  line(910, height-50, 910, height-30);
  line(1110, height-50, 1110, height-30);
  line(1310, height-50, 1310, height-30);
  line(1510, height-50, 1510, height-30);
  textSize(12);
  text("Season 1", 580, height-35);
  text("Season 2", 780, height-35);
  text("Season 3", 980, height-35);
  text("Season 4", 1180, height-35);
  text("Season 5", 1380, height-35);
  textSize(20);
  text("Affiliation", 10, 328);
  line(0, 300, 120, 300);
  line(0, 340, 120, 340);
  fill(255);
  stroke(0);
  for (int i = 0; i < 50; i++) {
    rect(510+i*20, height-100-barchart[i], 20, barchart[i]);
  }
  fill(100);
  stroke(0);
  for (int i = 0; i < 50; i++) {
    if ((i+1) == selectedEp) {                                   //Highlights the selected episode on bargraph.
      fill(0, 255, 0);
    }
    rect(510+i*20, height-100-barvalues[i], 20, barvalues[i]);
    fill(100);
  }
}

void drawControlsSection() {
  int half = height/2;
  text("Controls", 20, half + 168);
  textSize(12);
  fill(0);
  text("Animation Speed: ", 5, 890);
  line(0, height/2 + 140, 120, height/2 + 140);
  line(0, half + 180, 120, half + 180);
}

void drawBioSection() {
  line(430, 0, 430, height);
  if (characterImg != null) {
    float wscale = 220.0 / characterImg.width;
    int h = (int) (characterImg.height * wscale);
    image(characterImg, 165, 20, 220, h);
    textSize(20);
    text(characterName, 140, h+50);
    //textSize(11);
    //text(characterBio, 140, h+60, 270, height-(h+60));
    bio.setPosition(140, h+60);
    bio.setText(characterBio);
  }
}

void drawEpisodeSection(int q) {
  if (q == 0) {
    line(430, 800, width, 800);
  }
  textSize(20);
  String tempString;
  if (selectedEp != 0) {
    tempString = "Episode " + episodes.getString(selectedEp-1, 0) + " : " + episodes.getString(selectedEp-1, 1);
  } else {
    tempString = "Episode " + episodes.getString(0, 0) + " : " + episodes.getString(0, 1);
  }
  fill(0, 0, 0);
  text(tempString, 530, 825);
}

void drawMapSection() {
  image(map, 430, 0);
}

void customize(DropdownList ddl) {
  if (ddl.getName().equals("Affiliation")) {
    ddl.addItem("All Characters", 500);
    affiliationArray = new ArrayList<String>();
    nameToAffiliation = new HashMap<String, String>();
    for (int i = 1; i < bigCharacter.getRowCount (); i++) {
      nameToAffiliation.put(bigCharacter.getString(i, 0), bigCharacter.getString(i, 5));
      if (!affiliationArray.contains(bigCharacter.getString(i, 5))) {
        affiliationArray.add(bigCharacter.getString(i, 5));
        ddl.addItem(bigCharacter.getString(i, 5), affiliationArray.size());
      }
    }
    for (int i = 0; i < 50; i++) {
      barchart[i] = 0;
      barvalues[i] = 0;
    }
    for (int i = 1; i < smallerPaths.getRowCount (); i++) {
      barchart[smallerPaths.getInt(i, 0)-1] = barchart[smallerPaths.getInt(i, 0)-1] + 1;
      barvalues[smallerPaths.getInt(i, 0)-1] = barvalues[smallerPaths.getInt(i, 0)-1] + 1;
    }
    ddl.setValue(500);
  } else {
    ddl.addItem("Nothing Selected", 500);
    for (int i = 1; i < bigCharacter.getRowCount (); i++) {
      ddl.addItem(bigCharacter.getString(i, 0), i-1);
    }
    ddl.setValue(500);
  }
}

void controlEvent(ControlEvent event) {
  int currSelect = selected;
  if (event.getName() == "Character1") {
    dd1Clicked = false;
  }
  if (event.getName() == "Character2") {
    dd2Clicked = false;
  }
  if (event.getName() == "radioButton2") { // handles the full paths radio button toggle
    fullPathsBool = !fullPathsBool;
    if (fullPathsBool == true) {
      paths = loadTable("fullPaths.tsv", "header");
    } else if (fullPathsBool == false) {
      paths = loadTable("allpaths.tsv", "header");
    }
  }
  if (event.isGroup() && event.getGroup().getValue() != 500 && (event.getName().equals("Character1") || event.getName().equals("Character2"))) {
    String tempName = event.getGroup().getName();
    char temp = tempName.charAt(tempName.length()-1);

    selected = int(temp)-48;
    //selected = int(temp);
    int i = int(event.getGroup().getValue());
    String name = character1.getItem(int(event.getGroup().getValue())+1).getText();
    characterImg = loadImage(bigCharacter.getString(i+1, 2));
    characterName = name;
    characterBio = bigCharacter.getString(i+1, 1);
    drawEpisodeSection(1);
    //println("SELECTED DropDown : ", temp);
  } else if (event.isGroup() && !event.getGroup().getName().equals("Affiliation") && !event.isFrom("radioButton")) {
    int tempVal = int(event.getGroup().getValue());
    if (tempVal == 500 && ((currSelect==1 && character1.getCaptionLabel().getText() != "Nothing Selected") ||
      (currSelect==2 && character2.getCaptionLabel().getText() != "Nothing Selected")))
    { // These are special cases to fix selection when you change another dropdown to "nothing selected". It keeps the current one selected.
      selected = currSelect;
    } else if (event.getName() != "radioButton2") {
      t1 = !(character1.getCaptionLabel().getText().equals("Nothing Selected"));// Prevents a bug related to these not being updated in time.
      t2 = !(character2.getCaptionLabel().getText().equals("Nothing Selected"));
      selectNext();
      //println(event.getName());
    }
  }
  if (event.getName().equals("->") && isAnimation() && selectedEp < episodeMax && oneStep == false) {
    paused = false;
    tempEpisodeMin = episodeMin;
    tempEpisodeMax = episodeMax;
    episodeMin = selectedEp;
    episodeMax = selectedEp+1;
    drawAll();
    oneStep = true;
    if (selectedEp < episodeMax && selected != 0) {
      //selectedEp++;                                        //selectedep == epnum. Changed this elsewhere in code
      drawEpisodeSection(1);
    }
  } else if (event.getName().equals("->") && isCharacterPaths() && selectedEp < episodeMax) {
    selectedEp++;
  }
  if (event.getName().equals("<-") && selectedEp >1 && (selectedEp -1) >= episodeMin ) {
    selectedEp--; 
    t = 0;
    paused = true;
  }
  if (event.getName().equals("<<")) {  // 
    selectedEp = episodeMin;
    paused = true;
  }
  if (event.getName().equals("||>") && isAnimation()) {   //Pause Button action listener.
    paused = !paused;
  }
  if (event.isFrom("rangeController")) {
    episodeMin = int(event.getController().getArrayValue(0));
    episodeMax = int(event.getController().getArrayValue(1));
    if (selectedEp < episodeMin) {
      selectedEp = episodeMin;
    } else if (selectedEp > episodeMax) {
      selectedEp = episodeMax;
    }
    drawEpisodeSection(1);
  }
  if (event.getName().equals("Affiliation")) {
    /**
     * THIS IS WHERE YOU CAN INITIALIZE THE AFFILIATION AGGREGATION VARIABLE
     **/
    for (int i = 0; i < 50; i++) {
      barvalues[i] = 0;
    }
    if (event.getGroup().getValue() == 500) {
      for (int i = 1; i < smallerPaths.getRowCount (); i++) {
        barvalues[smallerPaths.getInt(i, 0)-1] = barvalues[smallerPaths.getInt(i, 0)-1] + 1;
      }
    } else {
      setBarvalues((int)event.getGroup().getValue());
    }
  }
}

void setBarvalues(int value) {
  for (int i = 1; i < smallerPaths.getRowCount (); i++) {
    String c = smallerPaths.getString(i, 1);
    if (nameToAffiliation.get(c).equals(affiliationArray.get(value-1))) {
      barvalues[smallerPaths.getInt(i, 0)-1] = barvalues[smallerPaths.getInt(i, 0)-1] + 1;
    }
  }
}

void selectNext() {
  if (t1 == true) {
    int j = int(character1.getValue());
    String name = character1.getCaptionLabel().getText();
    characterImg = loadImage(bigCharacter.getString(j+2, 2));
    characterName = name;
    characterBio = bigCharacter.getString(j+1, 1);
    selected = 1;
  } else if (t2 == true) {
    int j = int(character2.getValue());
    String name = character2.getCaptionLabel().getText();
    characterImg = loadImage(bigCharacter.getString(j+2, 2));
    characterName = name;
    characterBio = bigCharacter.getString(j+1, 1);
    selected = 2;
  } else {
    characterName = " ";
    characterBio = " ";
    characterImg = null;
    bio.setText("");
    selected = 0;
  }
}

void radioButton(int stateNumber) {
  state = stateNumber;
}


boolean isAnimation() {
  return state == 1;
}

boolean isCharacterPaths() {
  return state == 2;
}

boolean isAggregation() {
  return state == 3;
}

boolean isDeaths() {
  return state == 4;
}

void drawAggregation() {
  aggregation = new HashMap<Line, Integer>();
  float affil = affiliation.getValue();
  if (affil == 500) {
    for (int i = 1; i < paths.getRowCount (); i++) {
      int ep = paths.getInt(i, 0);
      if (ep >= episodeMin && ep <= episodeMax) {
        Line x = new Line(paths.getInt(i, 2), paths.getInt(i, 3), paths.getInt(i, 4), paths.getInt(i, 5));
        if (aggregation.containsKey(x)) {
          aggregation.put(x, aggregation.get(x) + 1);
        } else {
          aggregation.put(x, 1);
        }
      }
    }
  } else {
    for (int i = 1; i < paths.getRowCount (); i++) {
      int ep = paths.getInt(i, 0);
      if (ep >= episodeMin && ep <= episodeMax) {
        String car = paths.getString(i, 1);
        String aff = nameToAffiliation.get(car);
        if (affiliationArray.indexOf(aff) + 1 == affil) {
          Line x = new Line(paths.getInt(i, 2), paths.getInt(i, 3), paths.getInt(i, 4), paths.getInt(i, 5));
          if (aggregation.containsKey(x)) {
            aggregation.put(x, aggregation.get(x) + 1);
          } else {
            aggregation.put(x, 1);
          }
        }
      }
    }
  }
  for (Map.Entry entry : aggregation.entrySet ()) {
    stroke(50, 50, 50, 110);
    Line l = (Line) entry.getKey();
    int num = (Integer)entry.getValue();
    if (num < 10) {
      strokeWeight(num);
    } else if (num < 50) {
      strokeWeight(20);
    } else if (num < 100) {
      strokeWeight(30);
    } else {
      strokeWeight(40);
    }
    line(l.getX1() + xOffset, l.getY1(), l.getX2() + xOffset, l.getY2());
  }
  //println(aggregation.size());
}

class Line {

  int x1, y1, x2, y2;

  Line(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }

  int getX1() {
    return x1;
  }

  int getY1() {
    return y1;
  }

  int getX2() {
    return x2;
  }

  int getY2() {
    return y2;
  }

  boolean equals(Object obj) {
    Line line = (Line) obj;
    boolean a = (this.x1 == line.x1 && this.y1 == line.y1 && this.x2 == line.x2 && this.y2 == line.y2);
    boolean b = (this.x1 == line.x2 && this.y1 == line.y2 && this.x2 == line.x1 && this.y2 == line.y1);
    return a || b;
  }

  int hashCode() {
    return ((this.x1 + this.x2) * 349) + ((this.y1 + this.y2) * 509);
  }
}

