import ddf.minim.*;

// Global variables
Minim minim;
AudioPlayer song;
boolean showPart1 = true; // Toggle between Part 1 and Part 2 visualizations
int fadeInDuration = 5 * 60; // Duration for fade-in effect in frames
int fadeOutDuration = 5 * 60; // Duration for fade-out effect in frames
int fade = 0; // Variable for controlling fade effect
boolean isFadingOut = false; // Flag to indicate if the program is in fade-out phase
PShape group; // Group of 3D shapes
PVector[] initialPositions; // Array to store initial positions of shapes
int numBoxes = 60000; // Number of 3D boxes
float boxSize = 2; // Size of each 3D box
float sphereRadius = 310; // Radius for positioning boxes

void settings() {
    // Set the size of the window. Use the larger of the two dimensions for width and height.
    size(max(640, 600), max(720, 600), P3D);
}

void setup() {
    colorMode(HSB, 360, 100, 100, 100);
    noStroke();
    frameRate(60);

    // Initialize Minim for audio processing and play the song
    minim = new Minim(this);
    song = minim.loadFile("oj.mp3", 1024);
    song.play();

    // Create a group of 3D boxes and position them randomly in a spherical distribution
    group = createShape(GROUP);
    initialPositions = new PVector[numBoxes];
    for (int i = 0; i < numBoxes; i++) {
        PShape s = createShape(BOX, boxSize);
        s.setFill(color(240, 100, 100, 30));
        float theta = random(TWO_PI);
        float phi = random(PI);
        float r = random(sphereRadius);
        float x = r * sin(phi) * cos(theta);
        float y = r * sin(phi) * sin(theta);
        float z = r * cos(phi);
        s.translate(x, y, z);
        group.addChild(s);
        initialPositions[i] = new PVector(x, y, z);
    }
}

void draw() {
    // Handle the fade-in and fade-out effects
    if (frameCount < fadeInDuration) {
        fade = int(map(frameCount, 0, fadeInDuration, 0, 255));
    } else if (!song.isPlaying() && !isFadingOut) {
        isFadingOut = true;
        frameCount = 0;
    } else if (isFadingOut && frameCount < fadeOutDuration) {
        fade = int(map(frameCount, 0, fadeOutDuration, 255, 0));
    }

    if (isFadingOut && frameCount >= fadeOutDuration) {
        noLoop();
    }

    // Set the background with fade effect
    background(0, 0, 0, 255 - fade);

    // Toggle between Part 1 and Part 2 based on user input
    if (showPart1) {
        drawPart1();
    } else {
        drawPart2();
    }

    // Save each frame as an image file
   // saveFrame("frame-####.png");
}

void mousePressed() {
    // Toggle the visualization when the mouse is pressed
    showPart1 = !showPart1;
}

void drawPart1() {
    // Visualization for Part 1: Multiple rotating matrices of spheres
    for (int matrix = 0; matrix < 5; matrix++) {
        pushMatrix();
        translate(width/2, height/2, -500 + matrix * 300);
        float rotX = (sin(frameCount * 0.005 + matrix) + 1) * PI;
        float rotY = (cos(frameCount * 0.005 + matrix) + 1) * PI;
        rotateX(rotX);
        rotateY(rotY);

        for (int i = 0; i < 40; i++) {
            float size = 30 + sin(frameCount * 0.05 + i) * 15;
            float x = cos(i * 0.2) * 300;
            float y = sin(i * 0.2) * 300;
            float z = i * -15;

            for (int j = 0; j < 10; j++) {
                pushMatrix();
                translate(x, y, z - j * 5);
                rotateX(frameCount * 0.02);
                fill(240, 100, 100, 30);
                sphere(size - j);
                popMatrix();
            }
        }
        popMatrix();
    }
}

void drawPart2() {
    // Visualization for Part 2: Expanding and contracting group of boxes
    translate(width / 2, height / 2);
    float expandFactor = map(sin(frameCount * 0.02), -1, 1, 0.75, 1.4);

    for (int i = 0; i < group.getChildCount(); i++) {
        PShape box = group.getChild(i);
        PVector pos = initialPositions[i];

        float x = pos.x * expandFactor;
        float y = pos.y * expandFactor;
        float z = pos.z * expandFactor;

        box.resetMatrix();
        box.translate(x, y, z);
    }

    rotateX(frameCount * 0.005);
    rotateY(frameCount * 0.005);

    shape(group);
}
