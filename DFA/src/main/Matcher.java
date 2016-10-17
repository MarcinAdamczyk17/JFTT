package main;

public class Matcher {

	public void FAM(char[] T, int[][] d, int m){
		int n = T.length;
		int q = 0;
		int s;
		for(int i = 0; i < n; i++){
			q = d[q][T[i]-33];
			System.out.println(q);
			if(q == m){
				s = i + 1 - m;
				System.out.println("wzorzec z przesunieciem  " + s);
			}
		}
	}
}
