package main;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Test {

	public static void main(String[] args) {

		/*
		File input = new File("input.txt");
		Scanner scanner = null;
		
		try{
			scanner = new Scanner(input);
		}
		catch(FileNotFoundException e){
			e.printStackTrace();
		}
		
		while(scanner.hasNextLine()){
			System.out.println(scanner.nextLine());
		}
		*/
		
		String pattern = "ababaca";
		char[] E = {'a', 'b', 'c'};
		
		Transition t = new Transition();	
		int[][] d = t.computeTransitionFunction(pattern, E);
		
		String s = "aaba";
		char[] T = s.toCharArray();
		
		Matcher matcher = new Matcher();
		
		matcher.FAM(T, d, pattern.length());
	}

}
