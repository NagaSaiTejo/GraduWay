const express = require('express');
const Student = require('../models/Student');
const router = express.Router();

// Select a roadmap
router.post('/select', async (req, res) => {
  try {
    const { email, roadmapName } = req.body;
    if (!email || !roadmapName) {
      return res.status(400).json({ message: 'Email and roadmapName are required.' });
    }

    const student = await Student.findOne({ email });
    if (!student) {
      return res.status(404).json({ message: 'Student not found.' });
    }

    // Initialize progress to 0 if this roadmap hasn't been started
    if (!student.roadmapProgress) {
      student.roadmapProgress = new Map();
    }
    if (!student.roadmapProgress.has(roadmapName)) {
      student.roadmapProgress.set(roadmapName, 0);
    }

    student.activeRoadmap = roadmapName;
    await student.save();

    res.status(200).json({
      message: 'Roadmap selected successfully.',
      activeRoadmap: student.activeRoadmap,
      roadmapProgress: Object.fromEntries(student.roadmapProgress)
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Exit current roadmap
router.post('/exit', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required.' });
    }

    const student = await Student.findOne({ email });
    if (!student) {
      return res.status(404).json({ message: 'Student not found.' });
    }

    student.activeRoadmap = null;
    await student.save();

    res.status(200).json({
      message: 'Exited roadmap successfully.',
      activeRoadmap: student.activeRoadmap,
      roadmapProgress: Object.fromEntries(student.roadmapProgress)
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Complete a milestone test
router.post('/complete-milestone', async (req, res) => {
  try {
    const { email, roadmapName, newMilestoneIndex } = req.body;
    if (!email || !roadmapName || newMilestoneIndex === undefined) {
      return res.status(400).json({ message: 'Email, roadmapName, and newMilestoneIndex are required.' });
    }

    const student = await Student.findOne({ email });
    if (!student) {
      return res.status(404).json({ message: 'Student not found.' });
    }

    if (!student.roadmapProgress) {
      student.roadmapProgress = new Map();
    }

    const currentProgress = student.roadmapProgress.get(roadmapName) || 0;
    
    // Only update if the new index is greater than the current progress
    // newMilestoneIndex should be the index AFTER the just-completed milestone.
    // e.g. if they completed milestone 0, new progress should be 1.
    if (newMilestoneIndex > currentProgress) {
      student.roadmapProgress.set(roadmapName, newMilestoneIndex);
      
      // Also increase career score for passing a test
      student.careerScore += 5;
      
      await student.save();
    }

    res.status(200).json({
      message: 'Milestone completed successfully.',
      activeRoadmap: student.activeRoadmap,
      roadmapProgress: Object.fromEntries(student.roadmapProgress),
      careerScore: student.careerScore
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
